import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/repository/movie_repository.dart';
import '../utils/debounce.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository repository;
  final Debouncer debouncer = Debouncer(milliseconds: 700);

  SearchViewModel(this.repository);

  bool isLoading = false;
  List<MovieModel> results = [];
  String? error;

  void search(String query) {
    if (query.trim().isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    debouncer.run(() async {
      try {
        isLoading = true;
        error = null;
        notifyListeners();
        final res = await repository.searchMovies(query);
        results = res;
      } catch (e) {
        error = e.toString();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }
}
