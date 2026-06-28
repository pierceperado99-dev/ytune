package model

type SearchResult struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	Artist    string `json:"artist"`
	Thumbnail string `json:"thumbnail"`
	Duration  int    `json:"duration"`
	URL       string `json:"url"`
}

type StreamResponse struct {
	ID        string `json:"id"`
	StreamURL string `json:"stream_url"`
	Expires   bool   `json:"expires"`
}

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

type ErrorBody struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type SuccessBody struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data"`
}
