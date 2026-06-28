import 'package:equatable/equatable.dart';

import '../models/music_model.dart';

abstract class MusicEvent extends Equatable {
  const MusicEvent();
}

class SearchMusicRequested extends MusicEvent {
  final String query;

  const SearchMusicRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class PlayMusicRequested extends MusicEvent {
  final MusicModel music;

  const PlayMusicRequested(this.music);

  @override
  List<Object?> get props => [music];
}

class PauseMusicRequested extends MusicEvent {
  const PauseMusicRequested();

  @override
  List<Object?> get props => [];
}

class ResumeMusicRequested extends MusicEvent {
  const ResumeMusicRequested();

  @override
  List<Object?> get props => [];
}

class StopMusicRequested extends MusicEvent {
  const StopMusicRequested();

  @override
  List<Object?> get props => [];
}

class SeekMusicRequested extends MusicEvent {
  final Duration position;

  const SeekMusicRequested(this.position);

  @override
  List<Object?> get props => [position];
}

class VolumeChanged extends MusicEvent {
  final double volume;

  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

class PositionUpdated extends MusicEvent {
  final Duration position;

  const PositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class DurationUpdated extends MusicEvent {
  final Duration duration;

  const DurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

class PlaybackStarted extends MusicEvent {
  const PlaybackStarted();

  @override
  List<Object?> get props => [];
}

class PlaybackEnded extends MusicEvent {
  const PlaybackEnded();

  @override
  List<Object?> get props => [];
}

class PlaybackError extends MusicEvent {
  const PlaybackError();

  @override
  List<Object?> get props => [];
}
