import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DeckHistoryDB {
  static final DeckHistoryDB instance = DeckHistoryDB._init();
  static Database? _database;

  DeckHistoryDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('deck_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deck_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        timestamp INTEGER
      )
    ''');
  }

  Future<void> addOrUpdateDeck(int deckId, String name) async {
    final db = await instance.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.insert('deck_history', {
      'deck_id': deckId,
      'name': name,
      'timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<int>> getDeckHistory() async {
    final db = await instance.database;
    final result = await db.query('deck_history', orderBy: 'timestamp DESC');
    return result.map((deck) => deck['deck_id'] as int).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
