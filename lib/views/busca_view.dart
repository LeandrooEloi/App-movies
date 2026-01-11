import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/estado_view.dart';
import '../core/rotas.dart';
import '../viewmodels/busca_viewmodel.dart';
import '../widgets/erro_widget.dart';
import '../widgets/vazio_widget.dart';

class BuscaView extends StatefulWidget {
  const BuscaView({super.key});

  @override
  State<BuscaView> createState() => _BuscaViewState();
}

class _BuscaViewState extends State<BuscaView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuscaViewModel>().init();
    });

    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 600) {
        context.read<BuscaViewModel>().carregarMais();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _syncControllerText(String termo) {
    if (_controller.text == termo) return;
    _controller.text = termo;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: termo.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Consumer<BuscaViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _TopBarBusca(
                  titulo: 'Buscar',
                  onVoltar: () => Navigator.pop(context),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _SearchBarStitch(
                    controller: _controller,
                    onChanged: vm.onTermoChanged,
                    onClear: () {
                      _controller.clear();
                      vm.onTermoChanged('');
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    },
                  ),
                ),

                if (_controller.text.trim().isEmpty) ...[
                  _HistoricoStitch(
                    termos: vm.historico,
                    onTapTermo: (t) {
                      _syncControllerText(t);
                      vm.usarTermoDoHistorico(t);
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    },
                    onLimpar: vm.limparHistorico,
                  ),
                ],

                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (vm.estado == EstadoView.carregando) {
                        // No Stitch aparece skeleton, então usa skeleton aqui.
                        return const _ResultadosSkeleton();
                      }

                      if (vm.estado == EstadoView.erro) {
                        return ErroWidget(
                          mensagem: vm.mensagemErro ?? 'Erro inesperado.',
                          onTentarNovamente: () => vm.pesquisar(reset: true),
                        );
                      }

                      if (vm.estado == EstadoView.vazio) {
                        return const VazioWidget(mensagem: 'Nenhum resultado.');
                      }

                      return ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: vm.resultados.length + (vm.carregandoMais ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= vm.resultados.length) {
                            return const _BottomLoading();
                          }

                          final filme = vm.resultados[index];
                          return _ResultadoCardStitch(
                            titulo: filme.titulo,
                            sinopse: 'Toque para ver detalhes.',
                            nota: filme.nota,
                            posterPath: filme.posterPath,
                            generos: const [], // sua busca provavelmente não traz gêneros no card
                            onTap: () => Navigator.pushNamed(
                              context,
                              Rotas.detalhes,
                              arguments: filme.id,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBarBusca extends StatelessWidget {
  final String titulo;
  final VoidCallback onVoltar;

  const _TopBarBusca({
    required this.titulo,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg.withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onVoltar,
                icon: const Icon(Icons.chevron_left, size: 32, color: Color(0xFFEA2A33)),
                tooltip: 'Voltar',
              ),
              Expanded(
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 48), // spacer para centralizar o título
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBarStitch extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBarStitch({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchBarStitch> createState() => _SearchBarStitchState();
}

class _SearchBarStitchState extends State<_SearchBarStitch> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.55)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar filmes...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (hasText)
            IconButton(
              onPressed: widget.onClear,
              icon: Icon(Icons.cancel, color: Colors.white.withOpacity(0.55)),
              tooltip: 'Limpar',
            ),
        ],
      ),
    );
  }
}

class _HistoricoStitch extends StatelessWidget {
  final List<String> termos;
  final ValueChanged<String> onTapTermo;
  final VoidCallback onLimpar;

  const _HistoricoStitch({
    required this.termos,
    required this.onTapTermo,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    if (termos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pesquisas recentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.9)),
              ),
              const Spacer(),
              TextButton(
                onPressed: onLimpar,
                child: const Text(
                  'Limpar histórico',
                  style: TextStyle(color: Color(0xFFEA2A33), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: termos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final t = termos[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onTapTermo(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Principais resultados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}

class _ResultadoCardStitch extends StatelessWidget {
  final String titulo;
  final String sinopse;
  final double nota;
  final String? posterPath;
  final List<String> generos;
  final VoidCallback onTap;

  const _ResultadoCardStitch({
    required this.titulo,
    required this.sinopse,
    required this.nota,
    required this.posterPath,
    required this.generos,
    required this.onTap,
  });

  String? _imgUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  @override
  Widget build(BuildContext context) {
    final poster = _imgUrl(posterPath, size: 'w185');
    final texto = sinopse.trim().isEmpty ? 'Sem descrição.' : sinopse.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 102,
                child: poster == null
                    ? Container(
                  color: Colors.white.withOpacity(0.08),
                  child: const Icon(Icons.movie, color: Colors.white38),
                )
                    : CachedNetworkImage(
                  imageUrl: poster,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white.withOpacity(0.08)),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.08),
                    child: const Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 102,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              nota.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, height: 1.25, color: Colors.white.withOpacity(0.6)),
                    ),
                    const Spacer(),
                    if (generos.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: generos.take(2).map((g) => _ChipGenero(texto: g)).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipGenero extends StatelessWidget {
  final String texto;
  const _ChipGenero({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Colors.white.withOpacity(0.55),
        ),
      ),
    );
  }
}

class _ResultadosSkeleton extends StatelessWidget {
  const _ResultadosSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ResultadoSkeletonCard(),
    );
  }
}

class _ResultadoSkeletonCard extends StatelessWidget {
  const _ResultadoSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 72, height: 102, color: base),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 102,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(height: 12, width: 160, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                      const Spacer(),
                      Container(height: 12, width: 40, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 220, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                  const Spacer(),
                  Row(
                    children: [
                      Container(height: 14, width: 56, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                      const SizedBox(width: 8),
                      Container(height: 14, width: 56, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomLoading extends StatelessWidget {
  const _BottomLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            color: const Color(0xFFEA2A33),
            backgroundColor: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
    );
  }
}
