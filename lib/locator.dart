import 'package:get_it/get_it.dart';
import 'data/network/dio_client.dart';
import 'data/network/movie_api_service.dart';
import 'data/repository/movie_repository.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/bookmark_viewmodel.dart';
import 'data/db/hive_manager.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Network
  locator.registerLazySingleton<DioClient>(() => DioClient());
  locator.registerLazySingleton<MovieApiService>(
  () => MovieApiService(locator<DioClient>().dio),
);

  // Hive manager
  locator.registerLazySingleton<HiveManager>(() => HiveManager());

  // Repository
  locator.registerLazySingleton<MovieRepository>(
    () => MovieRepository(locator<MovieApiService>(), locator<HiveManager>()),
  );

  // ViewModels (factory so they can be created multiple times)
  locator.registerFactory(() => HomeViewModel(locator<MovieRepository>()));
  locator.registerFactory(() => SearchViewModel(locator<MovieRepository>()));
  locator.registerFactory(() => BookmarkViewModel(locator<MovieRepository>()));
}
