import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/estado_view.dart';
import '../viewmodels/detalhes_viewmodel.dart';
import '../widgets/erro_widget.dart';
import 'detalhes_skeleton.dart';

class DetalhesView extends StatefulWidget {
  final int idFilme;
  const DetalhesView({super.key, required this.idFilme});

  @override
  State<DetalhesView> createState() => _DetalhesViewState();
}

class _DetalhesViewState extends State<DetalhesView> {
  bool _sinopseExpandida = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetalhesViewModel>().carregar(widget.idFilme);
    });
  }

  String? _imgUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  double _bottomBarHeight(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return 12.0 + 48.0 + 16.0 + safeBottom;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Consumer<DetalhesViewModel>(
      builder: (context, vm, _) {
        final bool podeInteragir = vm.estado == EstadoView.conteudo;
        final bool mostrarBottomBar = vm.estado == EstadoView.conteudo;

        return Scaffold(
          backgroundColor: bg,
          extendBody: false,

          bottomNavigationBar: mostrarBottomBar
              ? _BottomBarStitch(
            podeInteragir: podeInteragir,
            favoritoAtivo: vm.ehFavorito,
            assistirDepoisAtivo: vm.ehAssistirDepois,
            onFavoritar: vm.alternarFavorito,
            onAssistirDepois: vm.alternarAssistirDepois,
          )
              : null,

          body: Builder(
            builder: (_) {
              if (vm.estado == EstadoView.carregando) {
                return const DetalhesSkeleton();
              }

              if (vm.estado == EstadoView.erro) {
                return SafeArea(
                  child: ErroWidget(
                    mensagem: vm.mensagemErro ?? 'Erro inesperado.',
                    onTentarNovamente: () => vm.carregar(widget.idFilme),
                  ),
                );
              }

              final f = vm.detalhes;
              if (f == null) {
                return const SafeArea(
                  child: Center(child: Text('Nenhum detalhe disponível.')),
                );
              }

              final backdrop = _imgUrl(f.backdropPath, size: 'w780');
              final poster = _imgUrl(f.posterPath, size: 'w342');

              // espaço final para não “encostar” na bottom bar
              final double bottomSpace =
                  (mostrarBottomBar ? _bottomBarHeight(context) : 0.0) + 48.0;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeaderBackdrop(
                      height: MediaQuery.of(context).size.height * 0.45,
                      backdropUrl: backdrop,
                      onBack: () => Navigator.pop(context),
                      onShare: () {},
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -58),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _PosterCard(posterUrl: poster),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _InfoBloco(
                                  titulo: f.titulo,
                                  nota: f.nota,
                                  dataLancamento: f.dataLancamento,
                                  generos: f.generos,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          const Text(
                            'Sinopse',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (f.sinopse == null || f.sinopse!.trim().isEmpty)
                                ? 'Sem sinopse disponível.'
                                : f.sinopse!.trim(),
                            maxLines: _sinopseExpandida ? null : 6,
                            overflow: _sinopseExpandida
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.72),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if ((f.sinopse ?? '').trim().length > 180)
                            TextButton(
                              onPressed: () => setState(() {
                                _sinopseExpandida = !_sinopseExpandida;
                              }),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: const Color(0xFFEA2A33),
                              ),
                              child: Text(
                                _sinopseExpandida ? 'Ver menos' : 'Ver mais',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // padding final (garante que a sinopse nunca fica atrás da bottom bar)
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: bottomSpace),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _HeaderBackdrop extends StatelessWidget {
  final double height;
  final String? backdropUrl;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _HeaderBackdrop({
    required this.height,
    required this.backdropUrl,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backdropUrl != null)
            CachedNetworkImage(
              imageUrl: backdropUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF2A2A2F)),
              errorWidget: (_, __, ___) => Container(color: const Color(0xFF2A2A2F)),
            )
          else
            Container(
              color: const Color(0xFF2A2A2F),
              child: const Icon(Icons.movie, color: Colors.white38, size: 56),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF121212),
                  Color.fromRGBO(18, 18, 18, 0.75),
                  Color.fromRGBO(18, 18, 18, 0.0),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
                  _GlassIconButton(icon: Icons.share, onTap: onShare),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final String? posterUrl;
  const _PosterCard({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: posterUrl == null
          ? Container(
        color: const Color(0xFF2A2A2F),
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      )
          : CachedNetworkImage(
        imageUrl: posterUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFF2A2A2F)),
        errorWidget: (_, __, ___) => Container(
          color: const Color(0xFF2A2A2F),
          child: const Icon(Icons.broken_image, color: Colors.white38),
        ),
      ),
    );
  }
}

class _InfoBloco extends StatelessWidget {
  final String titulo;
  final double nota;
  final String? dataLancamento;
  final List<String> generos;

  const _InfoBloco({
    required this.titulo,
    required this.nota,
    required this.dataLancamento,
    required this.generos,
  });

  @override
  Widget build(BuildContext context) {
    final ano = (dataLancamento != null && dataLancamento!.length >= 4)
        ? dataLancamento!.substring(0, 4)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.1),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              nota.toStringAsFixed(1),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.amber),
            ),
            if (ano != null) ...[
              const SizedBox(width: 8),
              Text('•', style: TextStyle(color: Colors.white.withOpacity(0.35))),
              const SizedBox(width: 8),
              Text(ano, style: TextStyle(color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w600)),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (generos.isNotEmpty)
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: generos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _GeneroChip(texto: generos[i], destaque: i == 0),
            ),
          ),
      ],
    );
  }
}

class _GeneroChip extends StatelessWidget {
  final String texto;
  final bool destaque;

  const _GeneroChip({required this.texto, required this.destaque});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFEA2A33);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: destaque ? primary.withOpacity(0.18) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: destaque ? Border.all(color: primary.withOpacity(0.30)) : null,
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: destaque ? primary : Colors.white.withOpacity(0.78),
        ),
      ),
    );
  }
}

class _BottomBarStitch extends StatelessWidget {
  final bool podeInteragir;
  final bool favoritoAtivo;
  final bool assistirDepoisAtivo;
  final VoidCallback onFavoritar;
  final VoidCallback onAssistirDepois;

  const _BottomBarStitch({
    required this.podeInteragir,
    required this.favoritoAtivo,
    required this.assistirDepoisAtivo,
    required this.onFavoritar,
    required this.onAssistirDepois,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFEA2A33);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.82),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: podeInteragir ? onFavoritar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: favoritoAtivo
                          ? primary.withOpacity(0.20)
                          : Colors.white.withOpacity(0.10),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10), // ✅ ajuda a caber
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      favoritoAtivo ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                    ),
                    label: const Text(
                      'Favoritos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: podeInteragir ? onAssistirDepois : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      assistirDepoisAtivo ? primary.withOpacity(0.85) : primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.schedule, size: 20),
                    label: const Text(
                      'Assistir depois',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
