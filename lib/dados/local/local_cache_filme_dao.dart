import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'banco_local.dart';
import '../../modelos/filme_detalhes.dart';

class LocalCacheFilmeDao {
  static const _tabela = 'cache_filme_resumo';

  Future<void> salvar(FilmeDetalhes detalhes) async {
    final Database db = await BancoLocal.instance();

    await db.insert(
      _tabela,
      {
        'id_filme': detalhes.id,
        'json': jsonEncode(detalhes.toJson()),
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FilmeDetalhes?> buscarSeValido(
      int idFilme, {
        Duration ttl = const Duration(hours: 24),
      }) async {
    final Database db = await BancoLocal.instance();

    final rows = await db.query(
      _tabela,
      where: 'id_filme = ?',
      whereArgs: [idFilme],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final atualizadoEmStr = rows.first['atualizado_em'] as String?;
    final jsonStr = rows.first['json'] as String?;

    if (atualizadoEmStr == null || jsonStr == null) return null;

    final atualizadoEm = DateTime.tryParse(atualizadoEmStr);
    if (atualizadoEm == null) return null;

    final expirou = DateTime.now().difference(atualizadoEm) > ttl;
    if (expirou) return null;

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return FilmeDetalhes.fromJson(map);
  }

  Future<void> limpar() async {
    final Database db = await BancoLocal.instance();
    await db.delete(_tabela);
  }

  Future<void> remover(int idFilme) async {
    final Database db = await BancoLocal.instance();
    await db.delete(_tabela, where: 'id_filme = ?', whereArgs: [idFilme]);
  }
}
