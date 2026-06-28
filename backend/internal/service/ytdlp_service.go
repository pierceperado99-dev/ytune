package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/rs/zerolog/log"
)

type YTDLPSearchResult struct {
	ID         string  `json:"id"`
	Title      string  `json:"title"`
	Uploader   string  `json:"uploader"`
	Thumbnail  string  `json:"thumbnail"`
	Duration   float64 `json:"duration"`
	WebpageURL string  `json:"webpage_url"`
}

type YTDLPService struct {
	ytdlpPath   string
	cookiesPath string
}

func NewYTDLPService(ytdlpPath string, cookiesPath string) *YTDLPService {
	return &YTDLPService{ytdlpPath: ytdlpPath, cookiesPath: cookiesPath}
}

func (s *YTDLPService) ensureCookies() string {
	if s.cookiesPath == "" {
		return ""
	}
	tmpDir := os.TempDir()
	tmpCookie := filepath.Join(tmpDir, "ytune-cookies.txt")

	if info, err := os.Stat(s.cookiesPath); err != nil {
		log.Warn().Err(err).Str("path", s.cookiesPath).Msg("cookies file not accessible")
		return ""
	} else {
		log.Info().Int64("size", info.Size()).Str("path", s.cookiesPath).Msg("cookies file found")
	}

	if _, err := os.Stat(tmpCookie); os.IsNotExist(err) {
		src, err := os.Open(s.cookiesPath)
		if err != nil {
			log.Warn().Err(err).Msg("failed to open cookies file")
			return ""
		}
		defer src.Close()
		dst, err := os.Create(tmpCookie)
		if err != nil {
			log.Warn().Err(err).Msg("failed to create temp cookies file")
			return ""
		}
		defer dst.Close()
		io.Copy(dst, src)
		log.Info().Str("tmp", tmpCookie).Msg("cookies copied to temp file")
	}
	return tmpCookie
}

func (s *YTDLPService) baseArgs() []string {
	cookieFile := s.ensureCookies()
	if cookieFile == "" {
		return nil
	}
	return []string{"--cookies", cookieFile}
}

func (s *YTDLPService) Search(ctx context.Context, query string) ([]YTDLPSearchResult, error) {
	searchQuery := fmt.Sprintf("ytsearch10:%s", query)

	ctx, cancel := context.WithTimeout(ctx, 120*time.Second)
	defer cancel()

	args := append(s.baseArgs(), searchQuery, "--dump-json", "--no-warnings", "--no-playlist", "--flat-playlist")
	cmd := exec.CommandContext(ctx, s.ytdlpPath, args...)

	stdout, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			log.Error().Err(err).Str("stderr", string(exitErr.Stderr)).Msg("yt-dlp search command failed")
		}
		return nil, fmt.Errorf("yt-dlp search failed: %w", err)
	}

	lines := strings.Split(strings.TrimSpace(string(stdout)), "\n")
	results := make([]YTDLPSearchResult, 0, len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		var result YTDLPSearchResult
		if err := json.Unmarshal([]byte(line), &result); err != nil {
			log.Warn().Err(err).Msg("failed to parse yt-dlp output line")
			continue
		}
		results = append(results, result)
	}

	return results, nil
}

func (s *YTDLPService) GetStreamURL(ctx context.Context, videoID string) (string, error) {
	url := fmt.Sprintf("https://www.youtube.com/watch?v=%s", videoID)

	ctx, cancel := context.WithTimeout(ctx, 120*time.Second)
	defer cancel()

	args := []string{
		"-f", "bestaudio[ext=m4a]/bestaudio/best",
		"--extractor-args", "youtube:player_client=android",
		"-g", url, "--no-warnings", "--no-playlist",
	}
	cmd := exec.CommandContext(ctx, s.ytdlpPath, args...)

	stdout, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			log.Error().Err(err).Str("stderr", string(exitErr.Stderr)).Msg("yt-dlp stream URL extraction failed")
		}
		return "", fmt.Errorf("yt-dlp stream URL extraction failed: %w", err)
	}

	streamURL := strings.TrimSpace(string(stdout))
	if streamURL == "" {
		return "", fmt.Errorf("yt-dlp returned empty stream URL")
	}

	return streamURL, nil
}
