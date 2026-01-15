import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Follows Clean Architecture principle - domain layer doesn't know about exceptions.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Database operation failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// Encryption/Decryption failures
class EncryptionFailure extends Failure {
  const EncryptionFailure({required super.message, super.code});
}

/// Backup operation failures
class BackupFailure extends Failure {
  const BackupFailure({required super.message, super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Cache failures (offline-first)
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}
