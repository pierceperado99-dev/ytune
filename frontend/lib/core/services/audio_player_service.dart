import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  Future<void> setSourceUrl(String url) async {
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(url)),
    );
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  bool get isPlaying => _player.playing;
  Duration get currentPosition => _player.position;
  Duration? get currentDuration => _player.duration;
  double get currentVolume => _player.volume;

  void dispose() {
    _player.dispose();
  }
}
