import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/estado_view.dart';
import '../core/rotas.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/erro_widget.dart';
import '../widgets/vazio_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _scrollPopulares = ScrollController();
  final _scrollTop = ScrollController();
  final _scrollNow = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().carregarPrimeiraPagina(CategoriaHome.populares);
    });

    _scrollPopulares.addListener(() => _onScroll(CategoriaHome.populares, _scrollPopulares));
    _scrollTop.addListener(() => _onScroll(CategoriaHome.maisAvaliados, _scrollTop));
    _scrollNow.addListener(() => _onScroll(CategoriaHome.emCartaz, _scrollNow));
  }

  void _onScroll(CategoriaHome c, ScrollController controller) {
    final vm = context.read<HomeViewModel>();
    if (!controller.hasClients) return;
    if (controller.position.pixels >= controller.position.maxScrollExtent - 600) {
      vm.carregarProximaPagina(c);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollPopulares.dispose();
    _scrollTop.dispose();
    _scrollNow.dispose();
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
            // TopAppBar (sticky + blur)
            _TopBar(
              titulo: 'MoviesPlus',
              onBuscar: () => Navigator.pushNamed(context, Rotas.busca),
              onMenu: () => Navigator.pushNamed(context, Rotas.minhaLista),
            ),

            // Tabs (sticky)
            Material(
              color: bg,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFEA2A33),
                labelColor: const Color(0xFFEA2A33),
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                tabs: const [
                  Tab(text: 'Populares'),
                  Tab(text: 'Bem avaliados'),
                  Tab(text: 'Em cartaz'),
                ],
                onTap: (i) {
                  final vm = context.read<HomeViewModel>();
                  final c = _categoriaByIndex(i);
                  if (!vm.jaCarregouAlgo(c)) vm.carregarPrimeiraPagina(c);
                },
              ),
            ),

            // Conteúdo
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AbaGridStitch(categoria: CategoriaHome.populares, controller: _scrollPopulares),
                  _AbaGridStitch(categoria: CategoriaHome.maisAvaliados, controller: _scrollTop),
                  _AbaGridStitch(categoria: CategoriaHome.emCartaz, controller: _scrollNow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CategoriaHome _categoriaByIndex(int i) {
    switch (i) {
      case 0:
        return CategoriaHome.populares;
      case 1:
        return CategoriaHome.maisAvaliados;
      default:
        return CategoriaHome.emCartaz;
    }
  }
}

class _TopBar extends StatelessWidget {
  final String titulo;
  final VoidCallback onBuscar;
  final VoidCallback onMenu;

  const _TopBar({
    required this.titulo,
    required this.onBuscar,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: bg.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu),
                tooltip: 'Minha lista',
              ),
              Expanded(
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: onBuscar,
                icon: const Icon(Icons.search),
                tooltip: 'Buscar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AbaGridStitch extends StatelessWidget {
  final CategoriaHome categoria;
  final ScrollController controller;

  const _AbaGridStitch({
    required this.categoria,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final itens = vm.itens(categoria);
        final estado = vm.estado(categoria);

        // Loading inicial = skeleton
        if (estado == EstadoView.carregando && itens.isEmpty) {
          return const _GridSkeleton();
        }

        if (estado == EstadoView.erro && itens.isEmpty) {
          return ErroWidget(
            mensagem: vm.mensagemErro(categoria) ?? 'Erro inesperado.',
            onTentarNovamente: () => vm.carregarPrimeiraPagina(categoria),
          );
        }

        if (estado == EstadoView.vazio && itens.isEmpty) {
          return const VazioWidget(mensagem: 'Nada por aqui ainda.');
        }

        return RefreshIndicator(
          onRefresh: () => vm.carregarPrimeiraPagina(categoria),
          child: CustomScrollView(
            controller: controller,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final filme = itens[index];
                      return _FilmeCardStitch(
                        titulo: filme.titulo,
                        nota: filme.nota,
                        posterPath: filme.posterPath,
                        mostrarHd: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Rotas.detalhes,
                          arguments: filme.id,
                        ),
                      );
                    },
                    childCount: itens.length,
                  ),
                ),
              ),

              // "Carregando mais filmes" no fim
              if (vm.carregandoMais(categoria))
                const SliverToBoxAdapter(child: _BottomLoadingStitch()),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _FilmeCardStitch extends StatelessWidget {
  final String titulo;
  final double nota;
  final String? posterPath;
  final bool mostrarHd;
  final VoidCallback onTap;

  const _FilmeCardStitch({
    required this.titulo,
    required this.nota,
    required this.posterPath,
    required this.mostrarHd,
    required this.onTap,
  });

  String? _imgUrl(String? path, {String size = 'w342'}) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  @override
  Widget build(BuildContext context) {
    final poster = _imgUrl(posterPath, size: 'w342');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.white.withOpacity(0.06),
                    child: poster == null
                        ? const Center(child: Icon(Icons.movie, color: Colors.white38))
                        : CachedNetworkImage(
                      imageUrl: poster,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: Colors.white.withOpacity(0.06)),
                      errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.white38)),
                    ),
                  ),
                ),
                if (mostrarHd)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA2A33),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'HD',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFEA2A33)),
                const SizedBox(width: 4),
                Text(
                  nota.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withOpacity(0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(color: base),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: 60,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(999)),
        ),
      ],
    );
  }
}

class _BottomLoadingStitch extends StatelessWidget {
  const _BottomLoadingStitch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: Color(0xFFEA2A33),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'CARREGANDO MAIS FILMES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
