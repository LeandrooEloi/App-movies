import 'package:dio/dio.dart';

import '../../modelos/filme.dart';
import '../../modelos/filme_detalhes.dart';
import '../../modelos/resposta_paginada.dart';

class FilmesTmdbDatasource {
  final Dio _dio;
  FilmesTmdbDatasource(this._dio);

  Future<RespostaPaginada<Filme>> populares({int pagina = 1}) async {
    final res = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': pagina},
    );

    return RespostaPaginada<Filme>.fromJson(
      Map<String, dynamic>.from(res.data),
          (json) => Filme.fromJson(json),
    );
  }

  Future<RespostaPaginada<Filme>> maisAvaliados({int pagina = 1}) async {
    final res = await _dio.get(
      '/movie/top_rated',
      queryParameters: {'page': pagina},
    );

    return RespostaPaginada<Filme>.fromJson(
      Map<String, dynamic>.from(res.data),
          (json) => Filme.fromJson(json),
    );
  }

  Future<RespostaPaginada<Filme>> emCartaz({int pagina = 1}) async {
    final res = await _dio.get(
      '/movie/now_playing',
      queryParameters: {'page': pagina},
    );

    return RespostaPaginada<Filme>.fromJson(
      Map<String, dynamic>.from(res.data),
          (json) => Filme.fromJson(json),
    );
  }

  Future<FilmeDetalhes> detalhes(int idFilme) async {
    final res = await _dio.get('/movie/$idFilme');
    return FilmeDetalhes.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<RespostaPaginada<Filme>> pesquisar(String termo, {int pagina = 1}) async {
    final res = await _dio.get(
      '/search/movie',
      queryParameters: {
        'query': termo,
        'page': pagina,
        'include_adult': false,
      },
    );

    return RespostaPaginada<Filme>.fromJson(
      Map<String, dynamic>.from(res.data),
          (json) => Filme.fromJson(json),
    );
  }
}
