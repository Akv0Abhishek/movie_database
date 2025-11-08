import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/repository/movie_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository repository;
  HomeViewModel(this.repository);

  bool isLoading = false;
  List<MovieModel> trending = [];
  List<MovieModel> nowPlaying = [];
  String? error;

  Future<void> fetchMovies() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      trending = await repository.getTrendingMovies();
      nowPlaying = await repository.getNowPlayingMovies();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
