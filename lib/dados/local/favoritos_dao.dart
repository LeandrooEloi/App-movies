import 'package:sqflite/sqflite.dart';
import 'banco_local.dart';

enum TipoListaSalva {
  favorito,
  assistirDepois,
}

extension TipoListaSalvaX on TipoListaSalva {
  String get valorDb {
    switch (this) {
      case TipoListaSalva.favorito:
        return 'favorito';
      case TipoListaSalva.assistirDepois:
        return 'assistir_depois';
    }
  }

  static TipoListaSalva fromDb(String valor) {
    if (valor == 'favorito') return TipoListaSalva.favorito;
    return TipoListaSalva.assistirDepois;
  }
}

class FavoritosDao {
  static const _tabela = 'filmes_salvos';

  Future<Database> get _db async => BancoLocal.instance();

  /// Salva o filme na lista (favorito ou assistir_depois).
  /// Como a PK é composta, usar ConflictAlgorithm.replace facilita o "toggle".
  Future<void> salvar({
    required int idFilme,
    required TipoListaSalva tipo,
  }) async {
    final db = await _db;

    await db.insert(
      _tabela,
      {
        'id_filme': idFilme,
        'tipo_lista': tipo.valorDb,
        'adicionado_em': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove o filme de uma lista específica.
  Future<void> remover({
    required int idFilme,
    required TipoListaSalva tipo,
  }) async {
    final db = await _db;

    await db.delete(
      _tabela,
      where: 'id_filme = ? AND tipo_lista = ?',
      whereArgs: [idFilme, tipo.valorDb],
    );
  }

  /// Verifica se um filme está salvo em uma lista específica.
  Future<bool> existe({
    required int idFilme,
    required TipoListaSalva tipo,
  }) async {
    final db = await _db;

    final res = await db.query(
      _tabela,
      columns: ['id_filme'],
      where: 'id_filme = ? AND tipo_lista = ?',
      whereArgs: [idFilme, tipo.valorDb],
      limit: 1,
    );

    return res.isNotEmpty;
  }

  /// Toggle: se existe, remove; se não existe, salva.
  /// Retorna true se ficou salvo no final, false se ficou removido.
  Future<bool> alternar({
    required int idFilme,
    required TipoListaSalva tipo,
  }) async {
    final jaExiste = await existe(idFilme: idFilme, tipo: tipo);
    if (jaExiste) {
      await remover(idFilme: idFilme, tipo: tipo);
      return false;
    } else {
      await salvar(idFilme: idFilme, tipo: tipo);
      return true;
    }
  }

  /// Lista IDs salvos de uma lista (em ordem do mais recente).
  Future<List<int>> listarIds({
    required TipoListaSalva tipo,
  }) async {
    final db = await _db;

    final res = await db.query(
      _tabela,
      columns: ['id_filme'],
      where: 'tipo_lista = ?',
      whereArgs: [tipo.valorDb],
      orderBy: 'adicionado_em DESC',
    );

    return res
        .map((e) => e['id_filme'])
        .whereType<int>()
        .toList();
  }

  /// Remove tudo de uma lista.
  Future<void> limparLista(TipoListaSalva tipo) async {
    final db = await _db;
    await db.delete(
      _tabela,
      where: 'tipo_lista = ?',
      whereArgs: [tipo.valorDb],
    );
  }
}
