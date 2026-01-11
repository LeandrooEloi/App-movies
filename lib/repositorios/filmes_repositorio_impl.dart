import '../dados/local/local_cache_filme_dao.dart';
import '../dados/tmdb/filmes_tmdb_datasource.dart';
import '../modelos/filme.dart';
import '../modelos/filme_detalhes.dart';
import '../modelos/resposta_paginada.dart';
import 'filmes_repositorio.dart';

class FilmesRepositorioImpl implements FilmesRepositorio {
  final FilmesTmdbDatasource _ds;
  final LocalCacheFilmeDao _cache;

  FilmesRepositorioImpl(this._ds, this._cache);

  @override
  Future<RespostaPaginada<Filme>> buscarPopulares({int pagina = 1}) {
    return _ds.populares(pagina: pagina);
  }

  @override
  Future<RespostaPaginada<Filme>> buscarMaisAvaliados({int pagina = 1}) {
    return _ds.maisAvaliados(pagina: pagina);
  }

  @override
  Future<RespostaPaginada<Filme>> buscarEmCartaz({int pagina = 1}) {
    return _ds.emCartaz(pagina: pagina);
  }

  @override
  Future<RespostaPaginada<Filme>> pesquisarFilmes(String termo, {int pagina = 1}) {
    return _ds.pesquisar(termo, pagina: pagina);
  }

  @override
  Future<FilmeDetalhes> buscarDetalhes(int idFilme) async {
    final cache = await _cache.buscarSeValido(idFilme);
    if (cache != null) return cache;

    final remoto = await _ds.detalhes(idFilme);
    await _cache.salvar(remoto);
    return remoto;
  }
}
