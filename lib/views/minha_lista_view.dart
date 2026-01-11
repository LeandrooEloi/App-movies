import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/estado_view.dart';
import '../core/rotas.dart';
import '../viewmodels/minha_lista_viewmodel.dart';
import '../widgets/erro_widget.dart';
import '../widgets/vazio_widget.dart';

class MinhaListaView extends StatefulWidget {
  const MinhaListaView({super.key});

  @override
  State<MinhaListaView> createState() => _MinhaListaViewState();
}

class _MinhaListaViewState extends State<MinhaListaView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MinhaListaViewModel>();
      vm.carregar(CategoriaLista.favoritos);
      vm.carregar(CategoriaLista.assistirDepois);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBarMinhaLista(
              titulo: 'Minha lista',
              onBack: () => Navigator.pop(context),
              onMenu: () {
                // opcional: abrir um menu (limpar lista, etc.)
                // showModalBottomSheet(...);
              },
            ),
            Material(
              color: bg,
              child: TabBar(
                controller: _tab,
                indicatorColor: const Color(0xFFEA2A33),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                tabs: const [
                  Tab(text: 'Favoritos'),
                  Tab(text: 'Assistir depois'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _AbaLista(categoria: CategoriaLista.favoritos),
                  _AbaLista(categoria: CategoriaLista.assistirDepois),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarMinhaLista extends StatelessWidget {
  final String titulo;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const _TopBarMinhaLista({
    required this.titulo,
    required this.onBack,
    required this.onMenu,
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
            color: bg.withOpacity(0.88),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left, size: 32),
                tooltip: 'Voltar',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.more_vert),
                tooltip: 'Opções',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AbaLista extends StatelessWidget {
  final CategoriaLista categoria;
  const _AbaLista({required this.categoria});

  String? _imgUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MinhaListaViewModel>(
      builder: (_, vm, __) {
        final estado = vm.estado(categoria);
        final itens = vm.itens(categoria);

        if (estado == EstadoView.carregando && itens.isEmpty) {
          // visual de "atualizando" igual ao Stitch
          return const _LoadingTopo();
        }

        if (estado == EstadoView.erro && itens.isEmpty) {
          return ErroWidget(
            mensagem: vm.mensagemErro(categoria) ?? 'Erro inesperado.',
            onTentarNovamente: () => vm.carregar(categoria),
          );
        }

        if (estado == EstadoView.vazio && itens.isEmpty) {
          return _VazioStitch(
            onExplorar: () => Navigator.pop(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.carregar(categoria),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            itemCount: itens.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final f = itens[index];
              final poster = _imgUrl(f.posterPath, size: 'w185');
              final sinopseCurta = (f.sinopse ?? '').trim();

              return _CardMinhaListaStitch(
                titulo: f.titulo,
                sinopse: sinopseCurta.isEmpty ? 'Sem descrição.' : sinopseCurta,
                nota: f.nota,
                genero: f.generos.isNotEmpty ? f.generos.first : null,
                posterUrl: poster,
                onTap: () => Navigator.pushNamed(
                  context,
                  Rotas.detalhes,
                  arguments: f.id,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LoadingTopo extends StatelessWidget {
  const _LoadingTopo();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: const [
        _RefreshingHeader(),
        SizedBox(height: 14),
        _SkeletonCard(),
        SizedBox(height: 12),
        _SkeletonCard(),
        SizedBox(height: 12),
        _SkeletonCard(),
      ],
    );
  }
}

class _RefreshingHeader extends StatelessWidget {
  const _RefreshingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFEA2A33),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Atualizando sua lista...',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }
}

class _CardMinhaListaStitch extends StatelessWidget {
  final String titulo;
  final String sinopse;
  final double nota;
  final String? genero;
  final String? posterUrl;
  final VoidCallback onTap;

  const _CardMinhaListaStitch({
    required this.titulo,
    required this.sinopse,
    required this.nota,
    required this.genero,
    required this.posterUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 96,
                child: posterUrl == null
                    ? Container(
                  color: Colors.white.withOpacity(0.06),
                  child: const Icon(Icons.movie, color: Colors.white38),
                )
                    : CachedNetworkImage(
                  imageUrl: posterUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white.withOpacity(0.06)),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.06),
                    child: const Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 96,
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Color(0xFFEA2A33)),
                            const SizedBox(width: 2),
                            Text(
                              nota.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEA2A33),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sinopse,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, height: 1.25, color: Colors.white.withOpacity(0.55)),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (genero != null && genero!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              genero!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.35)),
                      ],
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E).withOpacity(0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 64, height: 96, color: base),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(height: 12, width: 160, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                      const Spacer(),
                      Container(height: 12, width: 38, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 220, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                  const Spacer(),
                  Container(height: 18, width: 70, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VazioStitch extends StatelessWidget {
  final VoidCallback onExplorar;
  const _VazioStitch({required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1E),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.videocam_off, size: 54, color: Colors.white.withOpacity(0.22)),
        ),
        const SizedBox(height: 18),
        const Text(
          'Sua lista está vazia.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore novos filmes e adicione-os aos seus favoritos para vê-los aqui.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onExplorar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA2A33),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Explorar filmes', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}
