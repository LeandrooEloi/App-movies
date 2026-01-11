class FilmeDetalhes {
  final int id;
  final String titulo;
  final String? sinopse;
  final double nota;
  final String? dataLancamento;
  final List<String> generos;
  final String? posterPath;
  final String? backdropPath;

  FilmeDetalhes({
    required this.id,
    required this.titulo,
    required this.sinopse,
    required this.nota,
    required this.dataLancamento,
    required this.generos,
    required this.posterPath,
    required this.backdropPath,
  });

  factory FilmeDetalhes.fromJson(Map<String, dynamic> json) {
    // TMDb "details" normalmente traz: genres: [{id, name}, ...]
    // Mas para facilitar cache, também aceita: genres: ["Ação", "Drama"]
    final rawGenres = json['genres'];

    List<String> generos = [];

    if (rawGenres is List) {
      // Caso 1: lista de mapas (TMDb)
      final nomes1 = rawGenres
          .whereType<Map>()
          .map((g) => (g['name'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Caso 2: lista de strings (cache)
      final nomes2 = rawGenres
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      generos = nomes1.isNotEmpty ? nomes1 : nomes2;
    }

    final vote = json['vote_average'];

    return FilmeDetalhes(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      titulo: (json['title'] ?? '') as String,
      sinopse: json['overview'] as String?,
      nota: (vote is num) ? vote.toDouble() : 0.0,
      dataLancamento: json['release_date'] as String?,
      generos: generos,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
    );
  }

  /// JSON compatível com o mesmo esquema que o `fromJson` entende.
  /// (No cache, é comum manter o mesmo formato do TMDb).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titulo,
      'overview': sinopse,
      'vote_average': nota,
      'release_date': dataLancamento,
      'genres': generos.map((n) => {'name': n}).toList(),
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
    };
  }
}
