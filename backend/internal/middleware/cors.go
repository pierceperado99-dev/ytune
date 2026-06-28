package middleware

import (
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func NewCORSConfig(frontendURL string) cors.Config {
	return cors.Config{
		AllowOrigins:     frontendURL,
		AllowMethods:     "GET, POST, OPTIONS",
		AllowHeaders:     "Origin, Content-Type, Accept, Range",
		AllowCredentials: frontendURL != "*",
	}
}
