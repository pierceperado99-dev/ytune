package handler

import (
	"io"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/rs/zerolog/log"

	"YTune/backend/internal/model"
	"YTune/backend/internal/service"
	"YTune/backend/internal/utils"
)

type StreamHandler struct {
	youtubeService *service.YouTubeService
}

func NewStreamHandler(youtubeService *service.YouTubeService) *StreamHandler {
	return &StreamHandler{youtubeService: youtubeService}
}

func (h *StreamHandler) GetStream(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "video ID is required")
	}

	streamURL, err := h.youtubeService.GetStreamURL(c.Context(), id)
	if err != nil {
		log.Error().Err(err).Str("id", id).Msg("stream URL extraction failed")
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "stream extraction failed")
	}

	return utils.SuccessResponse(c, model.StreamResponse{
		ID:        id,
		StreamURL: streamURL,
		Expires:   true,
	})
}

func (h *StreamHandler) ProxyAudio(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "video ID is required")
	}

	streamURL, err := h.youtubeService.GetStreamURL(c.Context(), id)
	if err != nil {
		log.Error().Err(err).Str("id", id).Msg("audio proxy: stream extraction failed")
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "stream extraction failed")
	}

	req, err := http.NewRequestWithContext(c.Context(), http.MethodGet, streamURL, nil)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "failed to create upstream request")
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36")
	req.Header.Set("Referer", "https://www.youtube.com/")
	req.Header.Set("Origin", "https://www.youtube.com")

	if rangeHeader := c.Get("Range"); rangeHeader != "" {
		req.Header.Set("Range", rangeHeader)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Error().Err(err).Str("id", id).Msg("audio proxy: upstream request failed")
		return utils.ErrorResponse(c, fiber.StatusBadGateway, "failed to fetch audio stream")
	}
	defer resp.Body.Close()

	c.Set("Accept-Ranges", "bytes")
	c.Set("Content-Type", resp.Header.Get("Content-Type"))
	c.Set("Content-Length", resp.Header.Get("Content-Length"))

	if resp.StatusCode == http.StatusPartialContent {
		c.Set("Content-Range", resp.Header.Get("Content-Range"))
		c.Status(resp.StatusCode)
	} else if resp.StatusCode != http.StatusOK {
		log.Error().Int("upstream_status", resp.StatusCode).Str("id", id).Msg("audio proxy: unexpected upstream status")
		return utils.ErrorResponse(c, fiber.StatusBadGateway, "upstream returned unexpected status")
	}

	_, err = io.Copy(c.Response().BodyWriter(), resp.Body)
	if err != nil {
		log.Warn().Err(err).Str("id", id).Msg("audio proxy: stream copy interrupted")
	}

	return nil
}
