import 'package:flutter/foundation.dart';
import '../core/estado_view.dart';
import '../modelos/filme.dart';
import '../repositorios/filmes_repositorio.dart';
import '../modelos/resposta_paginada.dart';

enum CategoriaHome { populares, maisAvaliados, emCartaz }

class HomeViewModel extends ChangeNotifier {
  final FilmesRepositorio repo;
  HomeViewModel(this.repo);

  final Map<CategoriaHome, List<Filme>> _itens = {
    CategoriaHome.populares: [],
    CategoriaHome.maisAvaliados: [],
    CategoriaHome.emCartaz: [],
  };

  final Map<CategoriaHome, int> _paginaAtual = {
    CategoriaHome.populares: 0,
    CategoriaHome.maisAvaliados: 0,
    CategoriaHome.emCartaz: 0,
  };

  final Map<CategoriaHome, int> _totalPaginas = {
    CategoriaHome.populares: 1,
    CategoriaHome.maisAvaliados: 1,
    CategoriaHome.emCartaz: 1,
  };

  final Map<CategoriaHome, bool> _carregandoMais = {
    CategoriaHome.populares: false,
    CategoriaHome.maisAvaliados: false,
    CategoriaHome.emCartaz: false,
  };

  final Map<CategoriaHome, EstadoView> _estado = {
    CategoriaHome.populares: EstadoView.carregando,
    CategoriaHome.maisAvaliados: EstadoView.carregando,
    CategoriaHome.emCartaz: EstadoView.carregando,
  };

  final Map<CategoriaHome, String?> _mensagemErro = {
    CategoriaHome.populares: null,
    CategoriaHome.maisAvaliados: null,
    CategoriaHome.emCartaz: null,
  };

  // Getters
  List<Filme> itens(CategoriaHome c) => _itens[c] ?? const [];
  bool carregandoMais(CategoriaHome c) => _carregandoMais[c] ?? false;
  EstadoView estado(CategoriaHome c) => _estado[c] ?? EstadoView.carregando;
  String? mensagemErro(CategoriaHome c) => _mensagemErro[c];

  bool jaCarregouAlgo(CategoriaHome c) => (_paginaAtual[c] ?? 0) > 0;

  Future<void> carregarPrimeiraPagina(CategoriaHome c) async {
    _estado[c] = EstadoView.carregando;
    _mensagemErro[c] = null;
    notifyListeners();

    try {
      final resp = await _buscar(c, pagina: 1);
      _itens[c] = resp.resultados;
      _paginaAtual[c] = resp.pagina;
      _totalPaginas[c] = resp.totalPaginas;

      _estado[c] = _itens[c]!.isEmpty ? EstadoView.vazio : EstadoView.conteudo;
    } catch (_) {
      _mensagemErro[c] = 'Falha ao carregar. Verifique sua conexão e tente novamente.';
      _estado[c] = EstadoView.erro;
    }

    notifyListeners();
  }

  Future<void> carregarProximaPagina(CategoriaHome c) async {
    if (carregandoMais(c)) return;

    final atual = _paginaAtual[c] ?? 0;
    final total = _totalPaginas[c] ?? 1;
    if (atual >= total) return;

    _carregandoMais[c] = true;
    notifyListeners();

    try {
      final resp = await _buscar(c, pagina: atual + 1);

      final lista = List<Filme>.from(_itens[c] ?? const []);
      lista.addAll(resp.resultados);
      _itens[c] = lista;

      _paginaAtual[c] = resp.pagina;
      _totalPaginas[c] = resp.totalPaginas;
    } catch (_) {
      // aqui não muda para erro geral, só para de paginar
      // (pode mostrar SnackBar depois se quiser)
    } finally {
      _carregandoMais[c] = false;
      notifyListeners();
    }
  }

  Future<RespostaPaginada<Filme>> _buscar(CategoriaHome c, {required int pagina}) {
    switch (c) {
      case CategoriaHome.populares:
        return repo.buscarPopulares(pagina: pagina);
      case CategoriaHome.maisAvaliados:
        return repo.buscarMaisAvaliados(pagina: pagina);
      case CategoriaHome.emCartaz:
        return repo.buscarEmCartaz(pagina: pagina);
    }
  }
}
