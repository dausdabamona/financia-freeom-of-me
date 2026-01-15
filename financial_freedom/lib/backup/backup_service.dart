import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';

/// Backup service contract.
///
/// Handles encrypted manual backup to external storage.
/// Designed for user-controlled backup (not automatic cloud sync).
abstract class BackupService {
  /// Export encrypted backup to a file.
  /// Returns the file path of the created backup.
  Future<Either<Failure, String>> exportBackup();

  /// Import and decrypt backup from a file.
  /// Returns true if import was successful.
  Future<Either<Failure, bool>> importBackup(String filePath);

  /// Verify backup file integrity without importing.
  Future<Either<Failure, bool>> verifyBackup(String filePath);

  /// Get list of available backup files.
  Future<Either<Failure, List<BackupInfo>>> getAvailableBackups();
}

/// Information about a backup file
class BackupInfo {
  final String filePath;
  final DateTime createdAt;
  final int sizeBytes;
  final String? description;

  const BackupInfo({
    required this.filePath,
    required this.createdAt,
    required this.sizeBytes,
    this.description,
  });
}
