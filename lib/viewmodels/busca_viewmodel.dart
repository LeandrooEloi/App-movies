import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/estado_view.dart';
import '../dados/local/historico_busca_dao.dart';
import '../modelos/filme.dart';
import '../repositorios/filmes_repositorio.dart';

class BuscaViewModel extends ChangeNotifier {
  final FilmesRepositorio repo;
  final HistoricoBuscaDao historicoDao;

  BuscaViewModel(this.repo, this.historicoDao);

  EstadoView estado = EstadoView.vazio;
  String? mensagemErro;

  String _termo = '';
  Timer? _debounce;

  List<Filme> resultados = [];
  int _paginaAtual = 0;
  int _totalPaginas = 1;
  bool carregandoMais = false;

  List<String> historico = [];

  Future<void> init() async {
    historico = await historicoDao.listarTermos();
    notifyListeners();
  }

  void onTermoChanged(String valor) {
    _termo = valor;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      pesquisar(reset: true);
    });
  }

  Future<void> pesquisar({required bool reset}) async {
    final termo = _termo.trim();
    mensagemErro = null;

    if (termo.isEmpty) {
      resultados = [];
      estado = EstadoView.vazio;
      notifyListeners();
      return;
    }

    if (reset) {
      estado = EstadoView.carregando;
      resultados = [];
      _paginaAtual = 0;
      _totalPaginas = 1;
      notifyListeners();
    }

    try {
      final resp = await repo.pesquisarFilmes(termo, pagina: 1);
      resultados = resp.resultados;
      _paginaAtual = resp.pagina;
      _totalPaginas = resp.totalPaginas;

      estado = resultados.isEmpty ? EstadoView.vazio : EstadoView.conteudo;
      notifyListeners();

      // salva no histórico só quando deu certo (e não vazio)
      await historicoDao.salvarTermo(termo);
      historico = await historicoDao.listarTermos();
      notifyListeners();
    } catch (_) {
      mensagemErro = 'Falha ao pesquisar. Tente novamente.';
      estado = EstadoView.erro;
      notifyListeners();
    }
  }

  Future<void> carregarMais() async {
    if (carregandoMais) return;
    if (_paginaAtual >= _totalPaginas) return;

    carregandoMais = true;
    notifyListeners();

    try {
      final resp = await repo.pesquisarFilmes(_termo.trim(), pagina: _paginaAtual + 1);

      // evita repetir itens (por id)
      final ids = resultados.map((e) => e.id).toSet();
      final novos = resp.resultados.where((f) => !ids.contains(f.id)).toList();

      resultados = [...resultados, ...novos];
      _paginaAtual = resp.pagina;
      _totalPaginas = resp.totalPaginas;
    } finally {
      carregandoMais = false;
      notifyListeners();
    }
  }

  Future<void> limparHistorico() async {
    await historicoDao.limpar();
    historico = [];
    notifyListeners();
  }

  void usarTermoDoHistorico(String termo) {
    _termo = termo;
    // dispara busca imediata (sem esperar debounce)
    pesquisar(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
