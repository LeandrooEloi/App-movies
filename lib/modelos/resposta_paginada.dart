class RespostaPaginada<T> {
  final int pagina;
  final int totalPaginas;
  final List<T> resultados;

  RespostaPaginada({
    required this.pagina,
    required this.totalPaginas,
    required this.resultados,
  });

  factory RespostaPaginada.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonItem,
      ) {
    final results = (json['results'] as List?) ?? const [];

    return RespostaPaginada<T>(
      pagina: (json['page'] ?? 1) as int,
      totalPaginas: (json['total_pages'] ?? 1) as int,
      resultados: results
          .whereType<Map>()
          .map((e) => fromJsonItem(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
