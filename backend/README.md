# YTune Backend

Go backend API for a Flutter Web music player that searches and streams audio from YouTube via yt-dlp.

## Requirements

- Go 1.26+
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed and in PATH

## Install yt-dlp

### macOS (Homebrew)
```bash
brew install yt-dlp
```

### Linux / WSL
```bash
sudo apt update && sudo apt install yt-dlp
```

### Windows (Scoop)
```powershell
scoop install yt-dlp
```

### Verify
```bash
yt-dlp --version
```

## Setup

```bash
git clone <repo>
cd backend

cp .env.example .env

go mod tidy
go build ./...
```

## Run

```bash
go run ./cmd/server
```

Server starts on `http://localhost:8080`.

## API Documentation

### Health Check

```
GET /api/health
```

Response:
```json
{
  "status": "ok",
  "service": "music-api"
}
```

### Search

```
GET /api/search?q=<query>
```

Example:
```
GET /api/search?q=weekend%20blinding%20lights
```

Response:
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "4NRXx6U8ABo",
        "title": "The Weeknd - Blinding Lights",
        "artist": "The Weeknd",
        "thumbnail": "https://i.ytimg.com/vi/4NRXx6U8ABo/maxresdefault.jpg",
        "duration": 203,
        "url": "https://www.youtube.com/watch?v=4NRXx6U8ABo"
      }
    ]
  }
}
```

### Get Stream URL

```
GET /api/stream/<video_id>
```

Example:
```
GET /api/stream/dQw4w9WgXcQ
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "dQw4w9WgXcQ",
    "stream_url": "https://rr2---sn-...googlevideo.com/...",
    "expires": true
  }
}
```

### Proxy Audio (for browser playback)

```
GET /api/audio/<video_id>
```

Proxies the audio stream through the backend so the browser can play it without exposing YouTube URLs. Supports HTTP Range requests for seeking.

## Flutter Integration

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'http://localhost:8080';

Future<List<dynamic>> search(String query) async {
  final res = await http.get(Uri.parse('$baseUrl/api/search?q=$query'));
  final body = jsonDecode(res.body);
  return body['data']['results'];
}

String getStreamUrl(String videoId) {
  return '$baseUrl/api/audio/$videoId';
}
```

## Environment Variables

| Variable       | Default                    | Description            |
|----------------|----------------------------|------------------------|
| PORT           | 8080                       | Server port            |
| FRONTEND_URL   | http://localhost:5000       | Allowed CORS origin    |
| YTDLP_PATH     | yt-dlp                     | Path to yt-dlp binary  |

## Project Structure

```
backend/
├── cmd/server/main.go           # Entry point
├── internal/
│   ├── config/config.go         # Environment config
│   ├── handler/
│   │   ├── search_handler.go    # Search endpoint
│   │   └── stream_handler.go    # Stream & proxy endpoints
│   ├── service/
│   │   ├── youtube_service.go   # Business logic + validation
│   │   └── ytdlp_service.go     # yt-dlp command execution
│   ├── model/music.go           # Data types
│   ├── middleware/cors.go       # CORS configuration
│   └── utils/response.go        # JSON response helpers
├── .env
├── .env.example
├── go.mod
└── README.md
```
