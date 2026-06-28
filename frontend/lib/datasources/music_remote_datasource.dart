import 'package:dio/dio.dart';

import '../models/music_model.dart';

class MusicRemoteDatasource {
  final Dio _dio;

  MusicRemoteDatasource(this._dio);

  Future<List<MusicModel>> search(String query) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {'q': query},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final results = data['results'] as List;
      return results
          .map((json) => MusicModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(body['message'] as String? ?? 'Search failed');
  }

  Future<String> getStreamUrl(String id) async {
    final response = await _dio.get('/stream/$id');

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      return data['stream_url'] as String;
    }

    throw Exception(body['message'] as String? ?? 'Failed to get stream URL');
  }
}
