import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart'; 
import 'locator.dart';
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await setupLocator();

  runApp(const MoviesApp());
}

class MoviesApp extends StatefulWidget {
  const MoviesApp({super.key});

  @override
  State<MoviesApp> createState() => _MoviesAppState();
}

class _MoviesAppState extends State<MoviesApp> {
  late final AppLinks _appLinks;
  final GoRouter _router = AppRouter.router; // Use the static router instance

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial link (when app launched by deep link)
    final initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // Handle links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    print("Received deep link URI: $uri");
    // The incoming URI will be the full web URL: https://movie-recommendation-925cb.web.app/movie/1197137
    // or a custom scheme if you configure it for app_links.

    // If you are relying on Universal Links (web.app link), the URI will look like a web URL.
    // GoRouter can directly handle paths from web URLs.
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'movie') {
      // The path of the URI is '/movie/1197137'
      // You can directly tell GoRouter to navigate to this path.
      _router.go(uri.path); // Use go() for navigating to a new stack or push() for adding to current stack
      print("Navigating to GoRouter path: ${uri.path}");
    } else {
      print("Unknown deep link or non-movie path: $uri");
      // You might want to navigate to the home page or an error page for unhandled links
      _router.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Movies Database',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}