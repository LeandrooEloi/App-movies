import 'package:flutter/foundation.dart';
import '../core/estado_view.dart';
import '../modelos/filme_detalhes.dart';
import '../repositorios/filmes_repositorio.dart';
import '../dados/local/favoritos_dao.dart';

class DetalhesViewModel extends ChangeNotifier {
  final FilmesRepositorio repo;
  final FavoritosDao favoritosDao;

  DetalhesViewModel(this.repo, this.favoritosDao);

  EstadoView estado = EstadoView.vazio;
  String? mensagemErro;

  FilmeDetalhes? detalhes;

  bool ehFavorito = false;
  bool ehAssistirDepois = false;

  Future<void> carregar(int idFilme) async {
    estado = EstadoView.carregando;
    mensagemErro = null;
    notifyListeners();

    try {
      // carrega detalhes (rede)
      detalhes = await repo.buscarDetalhes(idFilme);


      // carrega flags (sqlite)
      ehFavorito = await favoritosDao.existe(
        idFilme: idFilme,
        tipo: TipoListaSalva.favorito,
      );
      ehAssistirDepois = await favoritosDao.existe(
        idFilme: idFilme,
        tipo: TipoListaSalva.assistirDepois,
      );

      estado = EstadoView.conteudo;
      notifyListeners();
    } catch (_) {
      mensagemErro = 'Falha ao carregar detalhes.';
      estado = EstadoView.erro;
      notifyListeners();
    }
  }

  Future<void> alternarFavorito() async {
    final id = detalhes?.id;
    if (id == null) return;

    ehFavorito = await favoritosDao.alternar(
      idFilme: id,
      tipo: TipoListaSalva.favorito,
    );
    notifyListeners();
  }

  Future<void> alternarAssistirDepois() async {
    final id = detalhes?.id;
    if (id == null) return;

    ehAssistirDepois = await favoritosDao.alternar(
      idFilme: id,
      tipo: TipoListaSalva.assistirDepois,
    );
    notifyListeners();
  }
}