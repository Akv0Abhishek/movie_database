import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/search_viewmodel.dart';
import '../locator.dart';
import '../utils/constants.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>(
      create: (_) => locator<SearchViewModel>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SearchViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: vm.search,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    vm.search('');
                  },
                ),
              ), 
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, model, _) {
                if (model.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (model.error != null) {
                  return Center(child: Text('Error: ${model.error}'));
                }
                if (model.results.isEmpty) {
                  final query = _controller.text.trim();
                  if (query.isEmpty) {
                    return const SearchPlaceholder();
                  } else {
                    return const Center(child: Text('No movies found'));
                  }
                }
                return ListView.builder(
                  itemCount: model.results.length,
                  itemBuilder: (context, index) {
                    final movie = model.results[index];
                    final poster = movie.posterPath != null ? '$TMDB_IMAGE_BASE${movie.posterPath}' : null;
                    return ListTile(
                      leading: poster != null ? Image.network(poster, width: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
                      title: Text(movie.title ?? 'Unknown'),
                      subtitle: Text(movie.releaseDate ?? ''),
                      onTap: () => context.pushNamed('movie_detail', pathParameters: {'id': movie.id.toString()}),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPlaceholder extends StatefulWidget {
  const SearchPlaceholder({super.key});

  @override
  State<SearchPlaceholder> createState() => _SearchPlaceholderState();
}

class _SearchPlaceholderState extends State<SearchPlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Search for movies',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}