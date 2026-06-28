// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../core/services/audio_player_service.dart';
import '../repositories/music_repository.dart';
import 'music_event.dart';
import 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final MusicRepository _repository;
  final AudioPlayerService _audioService;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;

  MusicBloc({
    required MusicRepository repository,
    required AudioPlayerService audioService,
  })  : _repository = repository,
        _audioService = audioService,
        super(const MusicState()) {
    on<SearchMusicRequested>(_onSearchMusicRequested);
    on<PlayMusicRequested>(_onPlayMusicRequested);
    on<PauseMusicRequested>(_onPauseMusicRequested);
    on<ResumeMusicRequested>(_onResumeMusicRequested);
    on<StopMusicRequested>(_onStopMusicRequested);
    on<SeekMusicRequested>(_onSeekMusicRequested);
    on<VolumeChanged>(_onVolumeChanged);
    on<PositionUpdated>(_onPositionUpdated);
    on<DurationUpdated>(_onDurationUpdated);
    on<PlaybackEnded>(_onPlaybackEnded);
    on<PlaybackError>(_onPlaybackError);
  }

  void _initPlayerListeners() {
    _positionSub?.cancel();
    _positionSub = _audioService.positionStream.listen((pos) {
      if (!isClosed) add(PositionUpdated(pos));
    });

    _durationSub?.cancel();
    _durationSub = _audioService.durationStream.listen((dur) {
      if (!isClosed && dur != null) add(DurationUpdated(dur));
    });

    _playerStateSub?.cancel();
    _playerStateSub = _audioService.playerStateStream.listen((playerState) {
      if (!isClosed) {
        if (playerState.processingState == ProcessingState.completed) {
          add(PlaybackEnded());
        }
      }
    });

    _playbackEventSub?.cancel();
    _playbackEventSub = _audioService.playbackEventStream.listen((event) {
      if (!isClosed && event.processingState == ProcessingState.error) {
        add(PlaybackError());
      }
    });
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _playbackEventSub?.cancel();
    _audioService.dispose();
    return super.close();
  }

  Future<void> _onSearchMusicRequested(
    SearchMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    emit(state.copyWith(searchResults: [], isLoading: true, hasSearched: true, clearError: true));
    try {
      final results = await _repository.searchMusic(event.query);
      emit(state.copyWith(searchResults: results, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Unable to connect to music service',
      ));
    }
  }

  Future<void> _onPlayMusicRequested(
    PlayMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        currentSong: event.music,
        isPlaying: false,
      ));

      final streamUrl = await _repository.getStreamUrl(event.music.id);
      await _audioService.setSourceUrl(streamUrl);
      _initPlayerListeners();
      _audioService.play();

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
        position: Duration.zero,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Unable to play this song',
      ));
    }
  }

  Future<void> _onPauseMusicRequested(
    PauseMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioService.pause();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onResumeMusicRequested(
    ResumeMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    _audioService.play();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> _onStopMusicRequested(
    StopMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioService.stop();
    emit(state.copyWith(
      isPlaying: false,
      currentSong: null,
      position: Duration.zero,
    ));
  }

  Future<void> _onSeekMusicRequested(
    SeekMusicRequested event,
    Emitter<MusicState> emit,
  ) async {
    await _audioService.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  Future<void> _onVolumeChanged(
    VolumeChanged event,
    Emitter<MusicState> emit,
  ) async {
    await _audioService.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  void _onPositionUpdated(
    PositionUpdated event,
    Emitter<MusicState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationUpdated(
    DurationUpdated event,
    Emitter<MusicState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onPlaybackEnded(
    PlaybackEnded event,
    Emitter<MusicState> emit,
  ) {
    emit(state.copyWith(
      isPlaying: false,
      position: Duration.zero,
    ));
  }

  void _onPlaybackError(
    PlaybackError event,
    Emitter<MusicState> emit,
  ) {
    emit(state.copyWith(
      isPlaying: false,
      isLoading: false,
      error: 'Unable to play this song',
    ));
  }
}
