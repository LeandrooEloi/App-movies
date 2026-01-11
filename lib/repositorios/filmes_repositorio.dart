import '../modelos/filme.dart';
import '../modelos/filme_detalhes.dart';
import '../modelos/resposta_paginada.dart';

abstract class FilmesRepositorio {
  Future<RespostaPaginada<Filme>> buscarPopulares({int pagina = 1});
  Future<RespostaPaginada<Filme>> buscarMaisAvaliados({int pagina = 1});
  Future<RespostaPaginada<Filme>> buscarEmCartaz({int pagina = 1});
  Future<FilmeDetalhes> buscarDetalhes(int idFilme);
  Future<RespostaPaginada<Filme>> pesquisarFilmes(String termo, {int pagina = 1});

}
