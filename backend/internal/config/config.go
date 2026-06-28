package config

import (
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port        string
	FrontendURL string
	YtdlpPath   string
	CookiesPath string
}

func Load() *Config {
	_ = godotenv.Load()

	return &Config{
		Port:        getEnv("PORT", "8080"),
		FrontendURL: getEnv("FRONTEND_URL", "http://localhost:5000"),
		YtdlpPath:   getEnv("YTDLP_PATH", "yt-dlp"),
		CookiesPath: getEnv("COOKIES_PATH", ""),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
