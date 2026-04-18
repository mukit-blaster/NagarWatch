import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Handles local caching for offline support (FR-7.2)
class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  LocalStorageService._();

  Database? _db;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'nagarwatch.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_issues (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE offline_evidence (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ── Auth token ────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async => _prefs?.setString('auth_token', token);
  String? getToken() => _prefs?.getString('auth_token');
  Future<void> clearToken() async => _prefs?.remove('auth_token');

  // ── Ward selection ────────────────────────────────────────────────────────
  Future<void> saveWardId(String wardId) async => _prefs?.setString('ward_id', wardId);
  String? getWardId() => _prefs?.getString('ward_id');
  Future<void> saveWardName(String wardName) async => _prefs?.setString('ward_name', wardName);
  String? getWardName() => _prefs?.getString('ward_name');

  // ── User data ─────────────────────────────────────────────────────────────
  Future<void> saveUser(Map<String, dynamic> user) async =>
      _prefs?.setString('user_data', jsonEncode(user));
  Map<String, dynamic>? getUser() {
    final s = _prefs?.getString('user_data');
    return s != null ? jsonDecode(s) as Map<String, dynamic> : null;
  }
  Future<void> clearUser() async => _prefs?.remove('user_data');

  // ── Offline issue queue ───────────────────────────────────────────────────
  Future<void> queueIssue(String id, Map<String, dynamic> data) async {
    await _db?.insert('offline_issues', {
      'id': id, 'data': jsonEncode(data),
      'synced': 0, 'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingIssues() async {
    final rows = await _db?.query('offline_issues', where: 'synced = 0') ?? [];
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> markIssueSynced(String id) async {
    await _db?.update('offline_issues', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Offline evidence queue ────────────────────────────────────────────────
  Future<void> queueEvidence(String id, Map<String, dynamic> data) async {
    await _db?.insert('offline_evidence', {
      'id': id, 'data': jsonEncode(data),
      'synced': 0, 'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingEvidence() async {
    final rows = await _db?.query('offline_evidence', where: 'synced = 0') ?? [];
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> markEvidenceSynced(String id) async {
    await _db?.update('offline_evidence', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
