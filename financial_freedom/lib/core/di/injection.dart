import 'package:get_it/get_it.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/services/freedom_calculator.dart';
import 'package:financial_freedom/data/repositories/financial_snapshot_repository_impl.dart';
import 'package:financial_freedom/data/repositories/daily_compass_repository_impl.dart';
import 'package:financial_freedom/data/repositories/financial_data_repository_impl.dart';
import 'package:financial_freedom/domain/repositories/financial_repository.dart';
import 'package:financial_freedom/domain/repositories/daily_compass_repository.dart';
import 'package:financial_freedom/domain/usecases/generate_daily_snapshot.dart';
import 'package:financial_freedom/domain/usecases/get_financial_reality.dart';
import 'package:financial_freedom/ui/bloc/compass/compass_bloc.dart';

final getIt = GetIt.instance;

/// Configure all dependencies for the application.
/// Called once at app startup.
Future<void> configureDependencies() async {
  // ============================================
  // Core
  // ============================================

  // Database - Encrypted SQLite (Offline-First Core)
  final database = await AppDatabase.create();
  getIt.registerSingleton<AppDatabase>(database);

  // Calculator
  getIt.registerLazySingleton<FreedomCalculator>(() => const FreedomCalculator());

  // ============================================
  // Repositories
  // ============================================

  getIt.registerLazySingleton<FinancialSnapshotRepository>(
    () => FinancialSnapshotRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<DailyCompassRepository>(
    () => DailyCompassRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<FinancialDataRepositoryImpl>(
    () => FinancialDataRepositoryImpl(getIt<AppDatabase>()),
  );

  // ============================================
  // Use Cases
  // ============================================

  getIt.registerLazySingleton<GetFinancialReality>(
    () => GetFinancialReality(getIt<FinancialSnapshotRepository>()),
  );

  getIt.registerLazySingleton<GenerateDailySnapshotUseCase>(
    () => GenerateDailySnapshotUseCase(
      financialDataRepository: getIt<FinancialDataRepositoryImpl>(),
      snapshotRepository: getIt<FinancialSnapshotRepository>(),
      compassRepository: getIt<DailyCompassRepository>(),
      calculator: getIt<FreedomCalculator>(),
    ),
  );

  // ============================================
  // BLoCs
  // ============================================

  getIt.registerFactory<CompassBloc>(
    () => CompassBloc(
      generateDailySnapshot: getIt<GenerateDailySnapshotUseCase>(),
      compassRepository: getIt<DailyCompassRepository>(),
    ),
  );
}
