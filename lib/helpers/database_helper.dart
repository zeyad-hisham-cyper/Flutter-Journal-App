/*
 * File Name   : database_helper.dart
 * Description : SQLite database manager for journal entries with CRUD operations.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /*
   * Get database instance, create if doesn't exist
   * Returns: Database instance
   */
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /*
   * Initialize database and create tables
   * Returns: Database instance
   */
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'journal_entries.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /*
   * Create database schema
   * Parameters: db - Database instance, version - Schema version
   */
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  /*
   * Upgrade database schema for new versions
   * Parameters: db - Database instance, oldVersion - Previous version, newVersion - Target version
   */
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE journal_entries ADD COLUMN isFavorite INTEGER DEFAULT 0',
      );
    }
  }

  /*
   * Insert new journal entry
   * Parameters: entry - JournalEntry to insert
   * Returns: ID of inserted entry
   */
  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap());
  }

  /*
   * Retrieve all journal entries ordered by date
   * Returns: List of all journal entries
   */
  Future<List<JournalEntry>> getEntries() async {
    final db = await database;
    final maps = await db.query('journal_entries', orderBy: 'date DESC');
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /*
   * Get single journal entry by ID
   * Parameters: id - Entry ID
   * Returns: JournalEntry or null if not found
   */
  Future<JournalEntry?> getEntry(int id) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return JournalEntry.fromMap(maps.first);
    }
    return null;
  }

  /*
   * Update existing journal entry
   * Parameters: entry - JournalEntry with updated data
   * Returns: Number of rows affected
   */
  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /*
   * Delete journal entry by ID
   * Parameters: id - Entry ID to delete
   * Returns: Number of rows deleted
   */
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  /*
   * Delete all journal entries
   * Returns: Number of rows deleted
   */
  Future<int> deleteAllEntries() async {
    final db = await database;
    return await db.delete('journal_entries');
  }

  /*
   * Search entries by title or content
   * Parameters: query - Search query string
   * Returns: List of matching entries
   */
  Future<List<JournalEntry>> searchEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /*
   * Get favorite entries only
   * Returns: List of favorite entries
   */
  Future<List<JournalEntry>> getFavoriteEntries() async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /*
   * Close database connection
   */
  Future<void> close() async {
    final db = _database;
    if (db == null) return;
    await db.close();
    _database = null;
  }
}
