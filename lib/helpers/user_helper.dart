/*
 * File Name   : user_helper.dart
 * Description : User authentication and profile management helper.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserHelper {
  static final UserHelper instance = UserHelper._init();
  static Database? _database;

  UserHelper._init();

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
   * Initialize database and create users table
   * Returns: Database instance
   */
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /*
   * Create database schema for users
   * Parameters: db - Database instance, version - Schema version
   */
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /*
   * Hash password using SHA256
   * Parameters: password - Plain text password
   * Returns: Hashed password string
   */
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /*
   * Register new user
   * Parameters: user - User object with credentials
   * Returns: User ID or null if email exists
   */
  Future<int?> registerUser(User user) async {
    final db = await database;

    final normalizedEmail = _normalizeEmail(user.email);

    // Check if email already exists
    final existing = await getUserByEmail(normalizedEmail);
    if (existing != null) {
      return null;
    }

    // Hash password before storing
    final hashedUser = user.copyWith(
      email: normalizedEmail,
      password: _hashPassword(user.password),
    );

    return await db.insert('users', hashedUser.toMap());
  }

  /*
   * Authenticate user with email and password
   * Parameters: email - User email, password - Plain text password
   * Returns: User object if valid, null if invalid
   */
  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);
    final normalizedEmail = _normalizeEmail(email);

    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /*
   * Get user by email
   * Parameters: email - User email
   * Returns: User object or null if not found
   */
  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final normalizedEmail = _normalizeEmail(email);

    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /*
   * Get user by ID
   * Parameters: id - User ID
   * Returns: User object or null if not found
   */
  Future<User?> getUserById(int id) async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /*
   * Update user profile
   * Parameters: user - User with updated data
   * Returns: Number of rows affected
   */
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /*
   * Get all registered users
   * Returns: List of all users
   */
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'createdAt DESC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  /*
   * Delete user account
   * Parameters: id - User ID
   * Returns: Number of rows deleted
   */
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
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
