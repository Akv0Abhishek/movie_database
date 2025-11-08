import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/home_viewmodel.dart';
import '../locator.dart';
import '../utils/constants.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => locator<HomeViewModel>()..fetchMovies(),
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Movies App')),
              body: Center(child: Text('Error: ${vm.error}')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Movies App'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.pushNamed('search'),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark),
                  onPressed: () => context.pushNamed('bookmarks'),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: vm.fetchMovies,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("Trending Movies",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      TrendingMoviesCarousel(),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("Now Playing",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          clipBehavior: Clip.none,
                          itemCount: vm.nowPlaying.length,
                          itemBuilder: (context, index) {
                            final movie = vm.nowPlaying[index];
                            return _MovieCard(
                              movieId: movie.id,
                              title: movie.title,
                              posterPath: movie.posterPath,
                              width: 140,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final int movieId;
  final String? title;
  final String? posterPath;
  final double? width;

  const _MovieCard({
    required this.movieId,
    this.title,
    this.posterPath,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final poster = posterPath != null ? '$TMDB_IMAGE_BASE$posterPath' : null;
    return GestureDetector(
      onTap: () => context.pushNamed('movie_detail', pathParameters: {'id': movieId.toString()}),
      child: Container(
        width: width ?? 140,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // less vertical margin
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: poster != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        poster,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stack) =>
                            Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.movie)),
                    ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title ?? 'Unknown',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TrendingMoviesCarousel extends StatefulWidget {
  const TrendingMoviesCarousel({super.key});

  @override
  State<TrendingMoviesCarousel> createState() => _TrendingMoviesCarouselState();
}

class _TrendingMoviesCarouselState extends State<TrendingMoviesCarousel> {
  late PageController _pageController;
  double _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(_pageListener);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final vm = Provider.of<HomeViewModel>(context, listen: false);
      final pageCount = vm.trending.length;
      if (pageCount <= 1) return;
      int nextPage = ((_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1) % pageCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _cancelAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _pageListener() {
    setState(() {
      _currentPage = _pageController.page ?? _pageController.initialPage.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute correct card and carousel height for any screen
    final double cardWidth = MediaQuery.of(context).size.width * 0.72;
    final double carouselHeight = cardWidth * 1.5 + 36; // 2:3 aspect poster + spacing/text
    return SizedBox(
      height: carouselHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final localCardWidth = constraints.maxWidth * 0.72;
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _cancelAutoScroll();
              } else if (notification is ScrollEndNotification) {
                _startAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: Provider.of<HomeViewModel>(context, listen: false).trending.length,
              itemBuilder: (context, index) {
                final vm = Provider.of<HomeViewModel>(context, listen: false);
                final movie = vm.trending[index];
                final double scale = (_currentPage - index).abs() < 1
                    ? 1 - 0.13 * (_currentPage - index).abs()
                    : 0.87;
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Transform.scale(
                      scale: scale,
                      child: _MovieCard(
                        movieId: movie.id,
                        title: movie.title,
                        posterPath: movie.posterPath,
                        width: localCardWidth,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
