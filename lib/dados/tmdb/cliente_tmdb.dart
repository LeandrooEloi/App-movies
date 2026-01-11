import 'package:dio/dio.dart';

class ClienteTmdb {
  final Dio dio;

  ClienteTmdb({
    required String apiKey,
  }) : dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {
        'api_key': apiKey,
        'language': 'pt-BR',
      },
    ),
  );
}
