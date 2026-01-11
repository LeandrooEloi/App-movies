import 'package:flutter/foundation.dart';

import '../core/estado_view.dart';
import '../dados/local/favoritos_dao.dart';
import '../modelos/filme_detalhes.dart';
import '../repositorios/filmes_repositorio.dart';

enum CategoriaLista {
  favoritos,
  assistirDepois,
}

class MinhaListaViewModel extends ChangeNotifier {
  final FilmesRepositorio repo;
  final FavoritosDao dao;

  MinhaListaViewModel(this.repo, this.dao);

  final Map<CategoriaLista, EstadoView> _estado = {
    CategoriaLista.favoritos: EstadoView.vazio,
    CategoriaLista.assistirDepois: EstadoView.vazio,
  };

  final Map<CategoriaLista, String?> _erro = {
    CategoriaLista.favoritos: null,
    CategoriaLista.assistirDepois: null,
  };

  final Map<CategoriaLista, List<FilmeDetalhes>> _itens = {
    CategoriaLista.favoritos: [],
    CategoriaLista.assistirDepois: [],
  };

  EstadoView estado(CategoriaLista c) => _estado[c] ?? EstadoView.vazio;
  String? mensagemErro(CategoriaLista c) => _erro[c];
  List<FilmeDetalhes> itens(CategoriaLista c) => _itens[c] ?? const [];

  TipoListaSalva _tipo(CategoriaLista c) {
    switch (c) {
      case CategoriaLista.favoritos:
        return TipoListaSalva.favorito;
      case CategoriaLista.assistirDepois:
        return TipoListaSalva.assistirDepois;
    }
  }

  Future<void> carregar(CategoriaLista c) async {
    _estado[c] = EstadoView.carregando;
    _erro[c] = null;
    notifyListeners();

    try {
      final ids = await dao.listarIds(tipo: _tipo(c));

      if (ids.isEmpty) {
        _itens[c] = [];
        _estado[c] = EstadoView.vazio;
        notifyListeners();
        return;
      }

      // Em paralelo: melhora muito o tempo (e ainda usa cache do MVP4).
      final futuros = ids.map((id) => repo.buscarDetalhes(id)).toList();
      final lista = await Future.wait(futuros);

      _itens[c] = lista;
      _estado[c] = EstadoView.conteudo;
      notifyListeners();
    } catch (_) {
      _erro[c] = 'Falha ao carregar sua lista.';
      _estado[c] = EstadoView.erro;
      notifyListeners();
    }
  }

  Future<void> recarregarTudo() async {
    await Future.wait([
      carregar(CategoriaLista.favoritos),
      carregar(CategoriaLista.assistirDepois),
    ]);
  }
}
