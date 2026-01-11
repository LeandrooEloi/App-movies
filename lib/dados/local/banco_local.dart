import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoLocal {
  static Database? _db;

  static const _nomeDb = 'moviesplus.db';
  static const _versaoDb = 3; // MVP4

  static Future<Database> instance() async {
    if (_db != null) return _db!;

    final pathDb = join(await getDatabasesPath(), _nomeDb);

    _db = await openDatabase(
      pathDb,
      version: _versaoDb,
      onCreate: (db, version) async {
        await _criarTabelas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // MVP3
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS filmes_salvos (
              id_filme INTEGER NOT NULL,
              tipo_lista TEXT NOT NULL,
              adicionado_em TEXT NOT NULL,
              PRIMARY KEY (id_filme, tipo_lista)
            )
          ''');
        }

        // MVP4
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cache_filme_resumo (
              id_filme INTEGER PRIMARY KEY,
              json TEXT NOT NULL,
              atualizado_em TEXT NOT NULL
            )
          ''');
        }
      },
    );

    return _db!;
  }

  static Future<void> _criarTabelas(Database db) async {
    // MVP2
    await db.execute('''
      CREATE TABLE IF NOT EXISTS historico_busca (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        termo TEXT NOT NULL,
        pesquisado_em TEXT NOT NULL
      )
    ''');

    // MVP3
    await db.execute('''
      CREATE TABLE IF NOT EXISTS filmes_salvos (
        id_filme INTEGER NOT NULL,
        tipo_lista TEXT NOT NULL,
        adicionado_em TEXT NOT NULL,
        PRIMARY KEY (id_filme, tipo_lista)
      )
    ''');

    // MVP4
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_filme_resumo (
        id_filme INTEGER PRIMARY KEY,
        json TEXT NOT NULL,
        atualizado_em TEXT NOT NULL
      )
    ''');
  }
}
