package service

import (
	"context"
	"fmt"
	"regexp"
	"strings"

	"YTune/backend/internal/model"
)

var (
	videoIDRegex = regexp.MustCompile(`^[a-zA-Z0-9_-]{11}$`)
	maxQueryLen  = 200
)

type YouTubeService struct {
	ytdlp *YTDLPService
}

func NewYouTubeService(ytdlp *YTDLPService) *YouTubeService {
	return &YouTubeService{ytdlp: ytdlp}
}

func (s *YouTubeService) Search(ctx context.Context, query string) ([]model.SearchResult, error) {
	query = strings.TrimSpace(query)

	if query == "" {
		return nil, fmt.Errorf("search query cannot be empty")
	}
	if len(query) > maxQueryLen {
		return nil, fmt.Errorf("search query too long (max %d characters)", maxQueryLen)
	}

	results, err := s.ytdlp.Search(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("search failed: %w", err)
	}

	musicResults := make([]model.SearchResult, 0, len(results))
	for _, r := range results {
		thumbnail := r.Thumbnail
		if thumbnail == "" {
			thumbnail = fmt.Sprintf("https://i.ytimg.com/vi/%s/maxresdefault.jpg", r.ID)
		}
		musicResults = append(musicResults, model.SearchResult{
			ID:        r.ID,
			Title:     r.Title,
			Artist:    r.Uploader,
			Thumbnail: thumbnail,
			Duration:  int(r.Duration),
			URL:       r.WebpageURL,
		})
	}

	return musicResults, nil
}

func (s *YouTubeService) GetStreamURL(ctx context.Context, videoID string) (string, error) {
	if !videoIDRegex.MatchString(videoID) {
		return "", fmt.Errorf("invalid video ID format")
	}

	streamURL, err := s.ytdlp.GetStreamURL(ctx, videoID)
	if err != nil {
		return "", fmt.Errorf("stream extraction failed: %w", err)
	}

	return streamURL, nil
}
