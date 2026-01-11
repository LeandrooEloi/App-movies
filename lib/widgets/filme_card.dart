import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../modelos/filme.dart';

class FilmeCard extends StatelessWidget {
  final Filme filme;
  final VoidCallback onTap;

  const FilmeCard({super.key, required this.filme, required this.onTap});

  String? _posterUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w342$path';
  }

  @override
  Widget build(BuildContext context) {
    final poster = _posterUrl(filme.posterPath);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: poster == null
                    ? Container(
                  color: const Color(0xFF2A2A2F),
                  child: const Icon(Icons.image_not_supported, color: Colors.white38),
                )
                    : CachedNetworkImage(
                  imageUrl: poster,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: const Color(0xFF2A2A2F)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF2A2A2F),
                    child: const Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filme.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('⭐ ${filme.nota.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
