import '../models/music_model.dart';

abstract class MusicRepository {
  Future<List<MusicModel>> searchMusic(String query);
  Future<String> getStreamUrl(String id);
}
