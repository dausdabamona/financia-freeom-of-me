import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/services/freedom_calculator.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/data/repositories/financial_data_repository_impl.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';
import 'package:financial_freedom/domain/repositories/financial_repository.dart';
import 'package:financial_freedom/domain/repositories/daily_compass_repository.dart';

/// Result of generating daily snapshot
class DailySnapshotResult {
  final FinancialSnapshot snapshot;
  final DailyCompassEntry compass;

  const DailySnapshotResult({
    required this.snapshot,
    required this.compass,
  });
}

/// Use case to generate daily financial snapshot and compass entry
///
/// This is the heart of the Snapshot Engine.
/// It reads all financial data, computes metrics, determines freedom phase,
/// and generates guidance for the day.
class GenerateDailySnapshotUseCase
    extends UseCase<DailySnapshotResult, NoParams> {
  final FinancialDataRepositoryImpl financialDataRepository;
  final FinancialSnapshotRepository snapshotRepository;
  final DailyCompassRepository compassRepository;
  final FreedomCalculator calculator;

  GenerateDailySnapshotUseCase({
    required this.financialDataRepository,
    required this.snapshotRepository,
    required this.compassRepository,
    required this.calculator,
  });

  @override
  Future<Either<Failure, DailySnapshotResult>> call(NoParams params) async {
    try {
      // 1. Collect all financial data
      final dataResult = await financialDataRepository.getFinancialData();

      return dataResult.fold(
        (failure) => Left(failure),
        (data) async {
          // 2. Generate snapshot ID and date
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final snapshotId = today.millisecondsSinceEpoch.toString();
          final compassId = '${snapshotId}_compass';

          // 3. Generate financial snapshot using calculator
          final snapshot = calculator.generateSnapshot(
            id: snapshotId,
            date: today,
            data: data,
          );

          // 4. Generate daily compass entry
          final compass = calculator.generateCompassEntry(
            id: compassId,
            date: today,
            data: data,
          );

          // 5. Save snapshot to database
          final saveSnapshotResult =
              await snapshotRepository.saveSnapshot(snapshot);
          if (saveSnapshotResult.isLeft()) {
            return Left(saveSnapshotResult.fold(
              (f) => f,
              (_) => const DatabaseFailure(message: 'Unknown error'),
            ));
          }

          // 6. Save compass entry to database
          final saveCompassResult =
              await compassRepository.saveCompassEntry(compass);
          if (saveCompassResult.isLeft()) {
            return Left(saveCompassResult.fold(
              (f) => f,
              (_) => const DatabaseFailure(message: 'Unknown error'),
            ));
          }

          // 7. Return result
          return Right(DailySnapshotResult(
            snapshot: snapshot,
            compass: compass,
          ));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to generate daily snapshot: $e',
      ));
    }
  }

  /// Check if snapshot exists for today
  Future<bool> hasSnapshotForToday() async {
    final result = await snapshotRepository.getTodaySnapshot();
    return result.fold(
      (_) => false,
      (snapshot) => snapshot != null,
    );
  }

  /// Get existing snapshot and compass for today if available
  Future<Either<Failure, DailySnapshotResult?>> getTodaySnapshotIfExists() async {
    try {
      final snapshotResult = await snapshotRepository.getTodaySnapshot();
      final compassResult = await compassRepository.getTodayCompass();

      return snapshotResult.fold(
        (failure) => Left(failure),
        (snapshot) {
          if (snapshot == null) {
            return const Right(null);
          }

          return compassResult.fold(
            (failure) => Left(failure),
            (compass) {
              if (compass == null) {
                return const Right(null);
              }

              return Right(DailySnapshotResult(
                snapshot: snapshot,
                compass: compass,
              ));
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get today snapshot: $e',
      ));
    }
  }
}
