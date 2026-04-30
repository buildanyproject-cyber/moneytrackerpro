import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../database/hive_database.dart';

// ============================================================
// Backup Service — Local file backup & restore
// ============================================================

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final HiveDatabase _db = HiveDatabase();

  // ─────────── Create Local Backup ───────────

  /// Creates a local JSON backup file
  /// Returns the file path of the created backup
  Future<String> createLocalBackup() async {
    if (kIsWeb) throw UnsupportedError('Local backup is not supported on Web');

    final data = _db.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${backupDir.path}/moneytracker_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  // ─────────── Restore from Local Backup ───────────

  /// Restores data from a local JSON backup file
  Future<void> restoreFromLocalFile(String filePath) async {
    if (kIsWeb) throw UnsupportedError('Local restore is not supported on Web');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;
    await _db.importAllData(data);
  }

  // ─────────── Get Backup Files ───────────

  /// Lists available local backup files
  Future<List<dynamic>> getLocalBackups() async {
    if (kIsWeb) return [];

    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/backups');
    if (!await backupDir.exists()) return [];

    return backupDir.listSync().where((f) => f.path.endsWith('.json')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  // ─────────── Export raw JSON string ───────────

  String getBackupJsonString() {
    final data = _db.exportAllData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ─────────── Delete Local Backup ───────────

  Future<void> deleteLocalBackup(String filePath) async {
    if (kIsWeb) return;

    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }
}
