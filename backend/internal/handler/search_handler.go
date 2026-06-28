package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/rs/zerolog/log"

	"YTune/backend/internal/service"
	"YTune/backend/internal/utils"
)

type SearchHandler struct {
	youtubeService *service.YouTubeService
}

func NewSearchHandler(youtubeService *service.YouTubeService) *SearchHandler {
	return &SearchHandler{youtubeService: youtubeService}
}

func (h *SearchHandler) Search(c *fiber.Ctx) error {
	query := c.Query("q")
	if query == "" {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "query parameter 'q' is required")
	}

	results, err := h.youtubeService.Search(c.Context(), query)
	if err != nil {
		log.Error().Err(err).Str("query", query).Msg("search failed")
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "search failed")
	}

	return utils.SuccessResponse(c, fiber.Map{
		"results": results,
	})
}
