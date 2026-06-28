import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/services/audio_player_service.dart';
import 'datasources/music_remote_datasource.dart';
import 'repositories/music_repository.dart';
import 'repositories/music_repository_impl.dart';
import 'bloc/music_bloc.dart';

final getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  _registerDependencies();

  runApp(const App());
}

void _registerDependencies() {
  getIt.registerLazySingleton<Dio>(() => DioClient.create());

  getIt.registerLazySingleton<MusicRemoteDatasource>(
    () => MusicRemoteDatasource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(getIt<MusicRemoteDatasource>()),
  );

  getIt.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerService(),
  );

  getIt.registerFactory<MusicBloc>(
    () => MusicBloc(
      repository: getIt<MusicRepository>(),
      audioService: getIt<AudioPlayerService>(),
    ),
  );
}
