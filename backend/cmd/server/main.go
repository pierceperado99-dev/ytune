package main

import (
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"YTune/backend/internal/config"
	"YTune/backend/internal/handler"
	"YTune/backend/internal/middleware"
	"YTune/backend/internal/model"
	"YTune/backend/internal/service"
	"YTune/backend/internal/utils"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	cfg := config.Load()

	ytdlpService := service.NewYTDLPService(cfg.YtdlpPath, cfg.CookiesPath)
	youtubeService := service.NewYouTubeService(ytdlpService)

	searchHandler := handler.NewSearchHandler(youtubeService)
	streamHandler := handler.NewStreamHandler(youtubeService)

	app := fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			log.Error().Err(err).Msg("unhandled error")
			return utils.ErrorResponse(c, fiber.StatusInternalServerError, "internal server error")
		},
		DisableStartupMessage: false,
	})

	app.Use(recover.New())
	app.Use(cors.New(middleware.NewCORSConfig(cfg.FrontendURL)))
	app.Use(limiter.New(limiter.Config{
		Max:        100,
		Expiration: 1 * time.Minute,
	}))

	app.Get("/api/health", func(c *fiber.Ctx) error {
		return c.JSON(model.HealthResponse{
			Status:  "ok",
			Service: "music-api",
		})
	})

	api := app.Group("/api")
	api.Get("/search", searchHandler.Search)
	api.Get("/stream/:id", streamHandler.GetStream)
	api.Get("/audio/:id", streamHandler.ProxyAudio)

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	go func() {
		log.Info().Str("port", cfg.Port).Msg("server starting")
		if err := app.Listen(":" + cfg.Port); err != nil {
			log.Fatal().Err(err).Msg("server failed to start")
		}
	}()

	<-quit
	log.Info().Msg("shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Fatal().Err(err).Msg("server shutdown failed")
	}
	log.Info().Msg("server stopped")
}
