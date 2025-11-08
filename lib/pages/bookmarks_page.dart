import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/bookmark_viewmodel.dart';
import '../locator.dart';
import '../utils/constants.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookmarkViewModel>(
      create: (_) => locator<BookmarkViewModel>()..loadBookmarks(),
      child: const _BookmarksView(),
    );
  }
}

class _BookmarksView extends StatelessWidget {
  const _BookmarksView();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Bookmarks')),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.bookmarks.isEmpty
                  ? const Center(child: Text('No bookmarks yet'))
                  : ListView.builder(
                      itemCount: vm.bookmarks.length,
                      itemBuilder: (context, index) {
                        final movie = vm.bookmarks[index];
                        final poster = movie.posterPath != null ? '$TMDB_IMAGE_BASE${movie.posterPath}' : null;
                        return ListTile(
                          leading: poster != null ? Image.network(poster, width: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
                          title: Text(movie.title ?? 'Unknown'),
                          subtitle: Text(movie.releaseDate ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => vm.removeBookmark(movie.id),
                          ),
                          onTap: () => context.pushNamed('movie_detail', pathParameters: {'id': movie.id.toString()}),
                        );
                      },
                    ),
        );
      },
    );
  }
}
