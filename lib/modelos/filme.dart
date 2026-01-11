class Filme {
  final int id;
  final String titulo;
  final String? posterPath;
  final double nota;

  Filme({
    required this.id,
    required this.titulo,
    required this.posterPath,
    required this.nota,
  });

  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      id: json['id'] ?? 0,
      titulo: (json['title'] ?? json['name'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      nota: (json['vote_average'] is num) ? (json['vote_average'] as num).toDouble() : 0.0,
    );
  }
}
