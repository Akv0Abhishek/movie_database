import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/movie_api_service.dart';
import '../models/movie_model.dart';
import '../db/hive_manager.dart';

class MovieRepository {
  final MovieApiService apiService;
  final HiveManager hive;

  MovieRepository(this.apiService, this.hive);

  Future<List<MovieModel>> getTrendingMovies() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) {
      return hive.getMovies(HiveManager.trendingBox);
    }
    final resp = await apiService.getTrendingMovies();
    await hive.saveMovies(HiveManager.trendingBox, resp.results);
    return resp.results;
  }

  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) {
      return hive.getMovies(HiveManager.nowPlayingBox);
    }
    final resp = await apiService.getNowPlayingMovies(page);
    await hive.saveMovies(HiveManager.nowPlayingBox, resp.results);
    return resp.results;
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    final resp = await apiService.searchMovies(query);
    return resp.results;
  }

  Future<MovieModel> getMovieDetails(int id) async {
    return apiService.getMovieDetails(id);
  }

  Future<void> bookmarkMovie(MovieModel movie) => hive.bookmarkMovie(movie);
  Future<List<MovieModel>> getBookmarks() => hive.getBookmarks();
  Future<void> removeBookmark(int id) => hive.removeBookmark(id);
  Future<bool> isBookmarked(int id) => hive.isBookmarked(id);
}
