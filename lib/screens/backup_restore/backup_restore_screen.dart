import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/backup_service.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Backup & Restore Screen
// ============================================================

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _localBackup = BackupService();
  bool _isLoading = false;
  String _status = '';
  List<FileSystemEntity> _localBackups = [];

  @override
  void initState() {
    super.initState();
    _loadLocalBackups();
  }

  void _setLoading(bool value, {String status = ''}) {
    setState(() {
      _isLoading = value;
      _status = status;
    });
  }

  Future<void> _loadLocalBackups() async {
    try {
      final backups = await _localBackup.getLocalBackups();
      setState(() {
        _localBackups = backups.cast<FileSystemEntity>();
      });
    } catch (_) {}
  }

  Future<void> _handleLocalBackup() async {
    _setLoading(true, status: 'Creating local backup...');
    try {
      await _localBackup.createLocalBackup();
      if (mounted) {
        AppUtils.showSnackBar(context, 'Backup saved successfully!');
      }
      await _loadLocalBackups();
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleLocalRestore(String filePath) async {
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Restore Backup',
      message:
          'This will replace all current data with the backup data. Proceed?',
      isDanger: true,
    );
    if (!confirm) return;

    _setLoading(true, status: 'Restoring from local backup...');
    try {
      await _localBackup.restoreFromLocalFile(filePath);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Data restored successfully! Please restart the app.',
        );
      }
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleDeleteBackup(String filePath) async {
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Delete Backup',
      message: 'Are you sure you want to delete this backup?',
      isDanger: true,
    );
    if (!confirm) return;

    try {
      await _localBackup.deleteLocalBackup(filePath);
      await _loadLocalBackups();
      if (mounted) {
        AppUtils.showSnackBar(context, 'Backup deleted');
      }
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _handleExportBackup(String filePath) async {
    try {
      if (mounted) {
        final xfile = XFile(filePath);
        await Share.shareXFiles(
          [xfile],
          text: 'MoneyTracker Pro Backup',
          subject: 'My Financial Backup',
        );
      }
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Export Error: $e', isError: true);
    }
  }

  String _formatBackupName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    // Extract timestamp from filename
    final match = RegExp(r'moneytracker_backup_(.+)\.json').firstMatch(fileName);
    if (match != null) {
      try {
        final raw = match.group(1)!.replaceAll('-', ':');
        // The timestamp format uses : replacing periods too, but let's handle it
        final dt = DateTime.parse(raw.replaceFirst(RegExp(r':(\d{3})'), '.\$1'));
        return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
      } catch (_) {}
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.cloud_sync_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Keep Your Data Safe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Backup your transactions, categories, and settings locally or securely to Google Drive.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Local Backup Section
              const Text(
                'Local Storage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Create Local Backup',
                icon: Icons.save_alt_rounded,
                onPressed: _isLoading ? null : _handleLocalBackup,
              ),
              const SizedBox(height: 16),

              // List of local backups
              if (_localBackups.isNotEmpty) ...[
                Text(
                  'Available Backups',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ..._localBackups.map((file) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined,
                          color: AppColors.primary),
                      title: Text(
                        _formatBackupName(file.path),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        file.path.split(Platform.pathSeparator).last,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore, color: AppColors.primary),
                            tooltip: 'Restore',
                            onPressed: _isLoading
                                ? null
                                : () => _handleLocalRestore(file.path),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                            tooltip: 'Export',
                            onPressed: _isLoading
                                ? null
                                : () => _handleExportBackup(file.path),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: _isLoading
                                ? null
                                : () => _handleDeleteBackup(file.path),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

              const Text(
                'Cloud Backup via Share',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'To backup to Google Drive or other cloud services, simply create a Local Backup above, tap the "Share" icon next to it, and securely save it anywhere you want!',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.primary
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: isDark ? Colors.black87 : Colors.white70,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
