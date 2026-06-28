import '../datasources/music_remote_datasource.dart';
import '../models/music_model.dart';
import 'music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDatasource _datasource;

  MusicRepositoryImpl(this._datasource);

  @override
  Future<List<MusicModel>> searchMusic(String query) async {
    return _datasource.search(query);
  }

  @override
  Future<String> getStreamUrl(String id) async {
    return _datasource.getStreamUrl(id);
  }
}
