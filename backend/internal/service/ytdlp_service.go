package service

import (
	"context"
	"encoding/json"
	"fmt"
	"os/exec"
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

func (s *YTDLPService) baseArgs() []string {
	if s.cookiesPath != "" {
		return []string{"--cookies", s.cookiesPath}
	}
	return nil
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

	args := append(s.baseArgs(),
		"-f", "bestaudio[ext=m4a]/140/251/bestaudio/best",
		"-g", url, "--no-warnings", "--no-playlist")
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
