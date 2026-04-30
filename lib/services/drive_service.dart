import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../database/hive_database.dart';

// ============================================================
// Google Drive Service — Backup & Restore via Google Drive
// ============================================================

/// Authenticated HTTP client wrapper for Google APIs
class _GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

class DriveService {
  static final DriveService _instance = DriveService._internal();
  factory DriveService() => _instance;
  DriveService._internal();

  final HiveDatabase _db = HiveDatabase();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;

  // ─────────── Sign In ───────────

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;

  // ─────────── Drive API client ───────────

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser == null) return null;
    }

    final authHeaders = await _currentUser!.authHeaders;
    final httpClient = _GoogleHttpClient(authHeaders);
    return drive.DriveApi(httpClient);
  }

  // ─────────── Backup to Google Drive ───────────

  Future<bool> backupToDrive() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final data = _db.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Check if backup file already exists
      final existingFileId = await _findBackupFile(driveApi);

      final media = drive.Media(
        Stream.value(utf8.encode(jsonString)),
        utf8.encode(jsonString).length,
      );

      if (existingFileId != null) {
        // Update existing file
        await driveApi.files.update(
          drive.File()..name = AppConstants.backupFileName,
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = AppConstants.backupFileName
          ..mimeType = AppConstants.backupMimeType;
        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────── Restore from Google Drive ───────────

  Future<bool> restoreFromDrive() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final fileId = await _findBackupFile(driveApi);
      if (fileId == null) return false;

      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final jsonString = utf8.decode(bytes);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      await _db.importAllData(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────── Find backup file in Drive ───────────

  Future<String?> _findBackupFile(drive.DriveApi driveApi) async {
    try {
      final result = await driveApi.files.list(
        q: "name = '${AppConstants.backupFileName}' and trashed = false",
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─────────── Check if backup exists ───────────

  Future<bool> hasBackupOnDrive() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;
      final fileId = await _findBackupFile(driveApi);
      return fileId != null;
    } catch (e) {
      return false;
    }
  }
}
