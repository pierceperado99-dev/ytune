import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isMobile;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    this.isLoading = false,
    required this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final btnSize = isMobile ? 40.0 : 48.0;
    final iconSize = isMobile ? 24.0 : 28.0;
    final playBtnSize = isMobile ? 40.0 : 44.0;
    final playIconSize = isMobile ? 24.0 : 28.0;
    final spacing = isMobile ? 6.0 : 8.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: btnSize,
          height: btnSize,
          child: IconButton(
            icon: Icon(
              Icons.skip_previous_rounded,
              color: Colors.grey[300],
              size: iconSize,
            ),
            onPressed: onPrevious,
            padding: EdgeInsets.zero,
            tooltip: 'Previous',
          ),
        ),
        SizedBox(width: spacing),
        Container(
          width: playBtnSize,
          height: playBtnSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: isLoading
                ? SizedBox(
                    width: playIconSize - 4,
                    height: playIconSize - 4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF0A0A0A),
                    size: playIconSize,
                  ),
            onPressed: isLoading ? null : onPlayPause,
            padding: EdgeInsets.zero,
            tooltip: isPlaying ? 'Pause' : 'Play',
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: btnSize,
          height: btnSize,
          child: IconButton(
            icon: Icon(
              Icons.skip_next_rounded,
              color: Colors.grey[300],
              size: iconSize,
            ),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            tooltip: 'Next',
          ),
        ),
      ],
    );
  }
}
