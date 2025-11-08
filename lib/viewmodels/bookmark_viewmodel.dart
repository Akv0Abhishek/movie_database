import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/repository/movie_repository.dart';

class BookmarkViewModel extends ChangeNotifier {
  final MovieRepository repository;

  BookmarkViewModel(this.repository);

  List<MovieModel> bookmarks = [];
  bool isLoading = false;

  Future<void> loadBookmarks() async {
    isLoading = true;
    notifyListeners();
    bookmarks = await repository.getBookmarks();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addBookmark(MovieModel movie) async {
    await repository.bookmarkMovie(movie);
    await loadBookmarks();
  }

  Future<void> removeBookmark(int id) async {
    await repository.removeBookmark(id);
    await loadBookmarks();
  }

  Future<bool> isBookmarked(int id) => repository.isBookmarked(id);
}
