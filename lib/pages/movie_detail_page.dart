import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/movie_model.dart';
import '../viewmodels/bookmark_viewmodel.dart';
import '../locator.dart';
import '../data/repository/movie_repository.dart';
import '../utils/constants.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  MovieModel? _movie;
  bool _isLoading = true;
  String? _error;
  late final MovieRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = locator<MovieRepository>();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movie = await _repo.getMovieDetails(widget.movieId);
      setState(() {
        _movie = movie;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _share() {
  if (_movie == null) return;
  final shareLink = 'https://movie-recommendation-925cb.web.app/movie/${_movie!.id}';
  Share.share('🎬 Check out this movie: ${_movie!.title ?? 'Movie'}\n$shareLink');
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookmarkViewModel>(
      create: (_) => locator<BookmarkViewModel>()..loadBookmarks(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_movie?.title ?? 'Movie Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(onPressed: _share, icon: const Icon(Icons.share)),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _movie == null
                    ? const Center(child: Text('Movie not found'))
                    : _DetailContent(movie: _movie!),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final MovieModel movie;
  const _DetailContent({required this.movie});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    final vm = locator<BookmarkViewModel>();
    vm.isBookmarked(widget.movie.id).then((value) {
      setState(() => _bookmarked = value);
    });
  }

  Future<void> _toggleBookmark() async {
    final vm = locator<BookmarkViewModel>();
    if (_bookmarked) {
      await vm.removeBookmark(widget.movie.id);
    } else {
      await vm.addBookmark(widget.movie);
    }
    final isBook = await vm.isBookmarked(widget.movie.id);
    setState(() => _bookmarked = isBook);
  }

  @override
  Widget build(BuildContext context) {
    final poster = widget.movie.posterPath != null ? '$TMDB_IMAGE_BASE${widget.movie.posterPath}' : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          poster != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 2 / 2.5,
                    child: Image.network(
                      poster,
                      width: double.infinity,
                      height: 420,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Container(height: 240, color: Colors.grey),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(widget.movie.title ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _toggleBookmark,
                icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 6),
              Text('${widget.movie.rating ?? 0}'),
              const SizedBox(width: 12),
              Text(widget.movie.releaseDate ?? ''),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.movie.overview ?? 'No overview available'),
        ],
      ),
    );
  }
}
