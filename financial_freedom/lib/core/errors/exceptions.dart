/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Thrown when database operations fail
class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code});
}

/// Thrown when encryption/decryption fails
class EncryptionException extends AppException {
  const EncryptionException({required super.message, super.code});
}

/// Thrown when backup operations fail
class BackupException extends AppException {
  const BackupException({required super.message, super.code});
}

/// Thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}
