import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/audio/data/datasources/audio_local_datasource.dart';
import '../../features/audio/data/datasources/audio_remote_datasource.dart';
import '../../features/audio/data/repositories/audio_repository_impl.dart';
import '../../features/audio/domain/repositories/audio_repository.dart';
import '../../features/audio/domain/usecases/get_audio_track.dart';
import '../../features/audio/presentation/bloc/audio_player_bloc.dart';
import '../../features/bible/data/datasources/bible_local_datasource.dart';
import '../../features/bible/data/datasources/bible_remote_datasource.dart';
import '../../features/bible/data/repositories/bible_repository_impl.dart';
import '../../features/bible/domain/repositories/bible_repository.dart';
import '../../features/bible/domain/usecases/get_books.dart';
import '../../features/bible/domain/usecases/get_verses.dart';
import '../../features/bible/presentation/bloc/bible_bloc.dart';
import '../../features/language/data/datasources/language_local_datasource.dart';
import '../../features/language/data/datasources/language_remote_datasource.dart';
import '../../features/language/data/repositories/language_repository_impl.dart';
import '../../features/language/domain/repositories/language_repository.dart';
import '../../features/language/domain/usecases/get_active_language.dart';
import '../../features/language/domain/usecases/get_languages.dart';
import '../../features/language/domain/usecases/set_active_language.dart';
import '../../features/language/presentation/bloc/language_cubit.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core External ──
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());

  // ── Core Services ──
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // ── Language Feature ──
  sl.registerLazySingleton<LanguageLocalDatasource>(
    () => LanguageLocalDatasourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<LanguageRemoteDatasource>(
    () => LanguageRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetLanguages(sl()));
  sl.registerLazySingleton(() => GetActiveLanguage(sl()));
  sl.registerLazySingleton(() => SetActiveLanguage(sl()));
  sl.registerFactory(
    () => LanguageCubit(
      getLanguages: sl(),
      getActiveLanguage: sl(),
      setActiveLanguage: sl(),
    ),
  );

  // ── Bible Feature ── (local asset files, no network needed)
  sl.registerLazySingleton<BibleLocalDatasource>(
    () => BibleLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<BibleRepository>(
    () => BibleRepositoryImpl(localDatasource: sl()),
  );
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => GetVerses(sl()));
  sl.registerFactory(
    () => BibleBloc(
      getBooks: sl(),
      getVerses: sl(),
    ),
  );

  // ── Audio Feature ──
  sl.registerLazySingleton<AudioLocalDatasource>(
    () => AudioLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<AudioRemoteDatasource>(
    () => AudioRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetAudioTrack(sl()));
  sl.registerLazySingleton(
    () => AudioPlayerBloc(getAudioTrack: sl()),
  );

  // ── Settings Feature ──
  sl.registerLazySingleton(() => SettingsCubit(sl()));
}
