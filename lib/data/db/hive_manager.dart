import 'package:hive/hive.dart';
import '../models/movie_model.dart';

class HiveManager {
  // Keys:
  static const String trendingBox = 'movies_trending';
  static const String nowPlayingBox = 'movies_now_playing';
  static const String bookmarksBox = 'movies_bookmarks';

  Future<void> saveMovies(String boxName, List<MovieModel> movies) async {
    final box = await Hive.openBox(boxName);
    final list = movies.map((m) => m.toJson()).toList();
    await box.put('data', list);
    await box.close();
  }

  Future<List<MovieModel>> getMovies(String boxName) async {
    final box = await Hive.openBox(boxName);
    final dynamic data = box.get('data', defaultValue: []);
    List<MovieModel> movies = [];
    if (data is List) {
      movies = data
          .map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    await box.close();
    return movies;
  }

  Future<void> bookmarkMovie(MovieModel movie) async {
    final box = await Hive.openBox(bookmarksBox);
    await box.put(movie.id.toString(), movie.toJson());
    await box.close();
  }

  Future<List<MovieModel>> getBookmarks() async {
    final box = await Hive.openBox(bookmarksBox);
    final values = box.values.toList();
    final list = values
        .map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    await box.close();
    return list;
  }

  Future<void> removeBookmark(int id) async {
    final box = await Hive.openBox(bookmarksBox);
    await box.delete(id.toString());
    await box.close();
  }

  Future<bool> isBookmarked(int id) async {
    final box = await Hive.openBox(bookmarksBox);
    final exists = box.containsKey(id.toString());
    await box.close();
    return exists;
  }
}
