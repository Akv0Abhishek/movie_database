import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../models/movie_response.dart';
import '../models/movie_model.dart';

part 'movie_api_service.g.dart';

@RestApi()
abstract class MovieApiService {
  factory MovieApiService(Dio dio) = _MovieApiService;

  @GET('/trending/movie/week')
  Future<MovieResponse> getTrendingMovies();

  @GET('/movie/now_playing')
  Future<MovieResponse> getNowPlayingMovies(@Query("page") int page);

  @GET('/search/movie')
  Future<MovieResponse> searchMovies(@Query("query") String query);

  @GET('/movie/{id}')
  Future<MovieModel> getMovieDetails(@Path("id") int id);
}