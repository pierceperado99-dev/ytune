import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import 'player_controls.dart';

class MusicPlayerBar extends StatelessWidget {
  final bool isMobile;

  const MusicPlayerBar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicBloc, MusicState>(
      buildWhen: (prev, current) =>
          prev.currentSong?.id != current.currentSong?.id ||
          prev.isPlaying != current.isPlaying ||
          prev.isLoading != current.isLoading ||
          prev.volume != current.volume,
      builder: (context, state) {
        if (state.currentSong == null) {
          return SizedBox(height: isMobile ? 64 : 80);
        }

        final music = state.currentSong!;
        final colorScheme = Theme.of(context).colorScheme;
        final artworkSize = isMobile ? 40.0 : 52.0;

        return Container(
          height: isMobile ? null : 80,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(12)),
            ),
          ),
          child: isMobile
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              music.thumbnail,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Container(
                                width: 36,
                                height: 36,
                                color: colorScheme.surface,
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  music.artist,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      PlayerControls(
                        isPlaying: state.isPlaying,
                        isLoading: state.isLoading,
                        isMobile: isMobile,
                        onPlayPause: () {
                          final bloc = context.read<MusicBloc>();
                          if (state.isPlaying) {
                            bloc.add(const PauseMusicRequested());
                          } else {
                            bloc.add(const ResumeMusicRequested());
                          }
                        },
                      ),
                      _ProgressSection(
                        duration: state.duration,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        music.thumbnail,
                        width: artworkSize,
                        height: artworkSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: artworkSize,
                          height: artworkSize,
                          color: colorScheme.surface,
                          child: Icon(
                            Icons.music_note_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            music.artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerControls(
                            isPlaying: state.isPlaying,
                            isLoading: state.isLoading,
                            isMobile: isMobile,
                            onPlayPause: () {
                              final bloc = context.read<MusicBloc>();
                              if (state.isPlaying) {
                                bloc.add(const PauseMusicRequested());
                              } else {
                                bloc.add(const ResumeMusicRequested());
                              }
                            },
                          ),
                          _ProgressSection(
                            duration: state.duration,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              state.volume == 0
                                  ? Icons.volume_off_rounded
                                  : state.volume < 0.5
                                      ? Icons.volume_down_rounded
                                      : Icons.volume_up_rounded,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            onPressed: () {
                              final bloc = context.read<MusicBloc>();
                              final newVolume =
                                  state.volume > 0 ? 0.0 : 1.0;
                              bloc.add(VolumeChanged(newVolume));
                            },
                            tooltip: state.volume > 0 ? 'Mute' : 'Unmute',
                          ),
                          SizedBox(
                            width: 80,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape:
                                    const RoundSliderThumbShape(
                                        enabledThumbRadius: 6),
                                overlayShape:
                                    const RoundSliderOverlayShape(
                                        overlayRadius: 14),
                                activeTrackColor:
                                    Colors.white.withAlpha(180),
                                inactiveTrackColor:
                                    Colors.white.withAlpha(25),
                                thumbColor: Colors.white,
                                overlayColor:
                                    Colors.white.withAlpha(30),
                              ),
                              child: Slider(
                                value: state.volume,
                                min: 0,
                                max: 1,
                                divisions: 100,
                                onChanged: (value) {
                                  context
                                      .read<MusicBloc>()
                                      .add(VolumeChanged(value));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final Duration duration;
  final bool isMobile;

  const _ProgressSection({required this.duration, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicBloc, MusicState>(
      buildWhen: (prev, current) =>
          prev.position != current.position ||
          prev.duration != current.duration,
      builder: (context, state) {
        final pos = state.position;
        final dur = state.duration;
        final colorScheme = Theme.of(context).colorScheme;
        final max = dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1.0;
        final value = dur.inMilliseconds > 0
            ? pos.inMilliseconds.toDouble().clamp(0.0, max)
            : 0.0;

        return Row(
          children: [
            SizedBox(width: isMobile ? 8 : 16),
            Text(
              _fmt(pos),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: isMobile ? 20 : null,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: isMobile ? 3 : 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: colorScheme.primary,
                    inactiveTrackColor: Colors.white.withAlpha(25),
                    thumbColor: Colors.white,
                    overlayColor: colorScheme.primary.withAlpha(30),
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: max,
                    onChanged: (v) {
                      context.read<MusicBloc>().add(
                            SeekMusicRequested(
                              Duration(milliseconds: v.toInt()),
                            ),
                          );
                    },
                  ),
                ),
              ),
            ),
            Text(
              _fmt(dur),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(width: isMobile ? 8 : 16),
          ],
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
