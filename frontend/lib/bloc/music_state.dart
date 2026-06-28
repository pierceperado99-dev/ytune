import 'package:equatable/equatable.dart';

import '../models/music_model.dart';

class MusicState extends Equatable {
  final List<MusicModel> searchResults;
  final bool isLoading;
  final bool hasSearched;
  final MusicModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final String? error;

  const MusicState({
    this.searchResults = const [],
    this.isLoading = false,
    this.hasSearched = false,
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.error,
  });

  MusicState copyWith({
    List<MusicModel>? searchResults,
    bool? isLoading,
    bool? hasSearched,
    MusicModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    String? error,
    bool clearError = false,
  }) {
    return MusicState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        searchResults,
        isLoading,
        hasSearched,
        currentSong,
        isPlaying,
        position,
        duration,
        volume,
        error,
      ];
}
