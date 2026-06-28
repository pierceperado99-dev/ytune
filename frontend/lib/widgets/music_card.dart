import 'package:flutter/material.dart';

import '../models/music_model.dart';

class MusicCard extends StatefulWidget {
  final MusicModel music;
  final bool isActive;
  final VoidCallback onPlay;
  final bool isMobile;

  const MusicCard({
    super.key,
    required this.music,
    this.isActive = false,
    required this.onPlay,
    this.isMobile = false,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  bool _isHovered = false;

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final music = widget.music;
    final thumbSize = widget.isMobile ? 44.0 : 52.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isActive
              ? colorScheme.primary.withAlpha(30)
              : (_isHovered
                  ? colorScheme.surface.withAlpha(200)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 8 : 12,
            vertical: widget.isMobile ? 2 : 4,
          ),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  music.thumbnail,
                  width: thumbSize,
                  height: thumbSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: thumbSize,
                    height: thumbSize,
                    color: colorScheme.surface,
                    child: Icon(
                      Icons.music_note_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (_isHovered || widget.isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: widget.onPlay,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            music.title,
            style: TextStyle(
              color: widget.isActive ? colorScheme.primary : Colors.white,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: widget.isMobile ? 13 : 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            music.artist,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: widget.isMobile ? 11 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _formatDuration(music.duration),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: widget.isMobile ? 11 : 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          onTap: widget.onPlay,
        ),
      ),
    );
  }
}
