import 'package:flutter_dotenv/flutter_dotenv.dart';

String get TMDB_BASE_URL => dotenv.env['TMDB_BASE_URL'] ?? "https://api.themoviedb.org/3";
String get TMDB_API_KEY => dotenv.env['TMDB_API_KEY'] ?? "";
String get TMDB_IMAGE_BASE => dotenv.env['TMDB_IMAGE_BASE'] ?? "https://image.tmdb.org/t/p/w500";
