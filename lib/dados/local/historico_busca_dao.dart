import 'package:sqflite/sqflite.dart';
import 'banco_local.dart';

class HistoricoBuscaDao {
  Future<Database> get _db async => BancoLocal.instance();

  Future<void> salvarTermo(String termo) async {
    final t = termo.trim();
    if (t.isEmpty) return;

    final db = await _db;

    // Remove duplicado (se existir) para subir para o topo
    await db.delete('historico_busca', where: 'termo = ?', whereArgs: [t]);

    await db.insert('historico_busca', {
      'termo': t,
      'pesquisado_em': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> listarTermos({int limite = 10}) async {
    final db = await _db;
    final res = await db.query(
      'historico_busca',
      columns: ['termo'],
      orderBy: 'pesquisado_em DESC',
      limit: limite,
    );
    return res.map((e) => (e['termo'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> limpar() async {
    final db = await _db;
    await db.delete('historico_busca');
  }
}
