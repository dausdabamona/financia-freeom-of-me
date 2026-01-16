import 'package:get_it/get_it.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/services/freedom_calculator.dart';
import 'package:financial_freedom/core/services/weekly_exit_simulator.dart';
import 'package:financial_freedom/core/services/scenario_engine.dart';

// Repository implementations
import 'package:financial_freedom/data/repositories/financial_snapshot_repository_impl.dart';
import 'package:financial_freedom/data/repositories/daily_compass_repository_impl.dart';
import 'package:financial_freedom/data/repositories/financial_data_repository_impl.dart';
import 'package:financial_freedom/data/repositories/account_repository_impl.dart';
import 'package:financial_freedom/data/repositories/asset_repository_impl.dart';
import 'package:financial_freedom/data/repositories/liability_repository_impl.dart';
import 'package:financial_freedom/data/repositories/monthly_baseline_repository_impl.dart';
import 'package:financial_freedom/data/repositories/time_profile_repository_impl.dart';
import 'package:financial_freedom/data/repositories/exit_scenario_repository_impl.dart';
import 'package:financial_freedom/data/repositories/weekly_projection_repository_impl.dart';

// Repository interfaces
import 'package:financial_freedom/domain/repositories/financial_repository.dart';
import 'package:financial_freedom/domain/repositories/daily_compass_repository.dart';
import 'package:financial_freedom/domain/repositories/account_repository.dart';
import 'package:financial_freedom/domain/repositories/asset_repository.dart';
import 'package:financial_freedom/domain/repositories/liability_repository.dart';
import 'package:financial_freedom/domain/repositories/monthly_baseline_repository.dart';
import 'package:financial_freedom/domain/repositories/time_profile_repository.dart';
import 'package:financial_freedom/domain/repositories/exit_scenario_repository.dart';
import 'package:financial_freedom/domain/repositories/weekly_projection_repository.dart';

// Use cases
import 'package:financial_freedom/domain/usecases/generate_daily_snapshot.dart';
import 'package:financial_freedom/domain/usecases/get_financial_reality.dart';
import 'package:financial_freedom/domain/usecases/save_account.dart';
import 'package:financial_freedom/domain/usecases/save_baseline.dart';
import 'package:financial_freedom/domain/usecases/save_asset.dart';
import 'package:financial_freedom/domain/usecases/save_liability.dart';
import 'package:financial_freedom/domain/usecases/save_time_profile.dart';

// BLoCs
import 'package:financial_freedom/ui/bloc/compass/compass_bloc.dart';
import 'package:financial_freedom/ui/bloc/onboarding/onboarding.dart';
import 'package:financial_freedom/ui/bloc/exit_simulator/exit_simulator.dart';

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

  // Weekly Exit Simulator
  getIt.registerLazySingleton<WeeklyExitSimulator>(() => const WeeklyExitSimulator());

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

  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<LiabilityRepository>(
    () => LiabilityRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MonthlyBaselineRepository>(
    () => MonthlyBaselineRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<TimeProfileRepository>(
    () => TimeProfileRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ExitScenarioRepository>(
    () => ExitScenarioRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<WeeklyProjectionRepository>(
    () => WeeklyProjectionRepositoryImpl(getIt<AppDatabase>()),
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

  getIt.registerLazySingleton<SaveAccountUseCase>(
    () => SaveAccountUseCase(getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<SaveBaselineUseCase>(
    () => SaveBaselineUseCase(getIt<MonthlyBaselineRepository>()),
  );

  getIt.registerLazySingleton<SaveAssetUseCase>(
    () => SaveAssetUseCase(getIt<AssetRepository>()),
  );

  getIt.registerLazySingleton<SaveLiabilityUseCase>(
    () => SaveLiabilityUseCase(getIt<LiabilityRepository>()),
  );

  getIt.registerLazySingleton<SaveTimeProfileUseCase>(
    () => SaveTimeProfileUseCase(getIt<TimeProfileRepository>()),
  );

  // ============================================
  // Services
  // ============================================

  getIt.registerLazySingleton<ScenarioEngine>(
    () => ScenarioEngine(
      simulator: getIt<WeeklyExitSimulator>(),
      scenarioRepository: getIt<ExitScenarioRepository>(),
      projectionRepository: getIt<WeeklyProjectionRepository>(),
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

  getIt.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      generateDailySnapshot: getIt<GenerateDailySnapshotUseCase>(),
    ),
  );

  getIt.registerFactory<AccountSetupBloc>(
    () => AccountSetupBloc(
      accountRepository: getIt<AccountRepository>(),
      saveAccount: getIt<SaveAccountUseCase>(),
    ),
  );

  getIt.registerFactory<BaselineBloc>(
    () => BaselineBloc(
      baselineRepository: getIt<MonthlyBaselineRepository>(),
      saveBaseline: getIt<SaveBaselineUseCase>(),
    ),
  );

  getIt.registerFactory<AssetLiabilityBloc>(
    () => AssetLiabilityBloc(
      assetRepository: getIt<AssetRepository>(),
      liabilityRepository: getIt<LiabilityRepository>(),
      saveAsset: getIt<SaveAssetUseCase>(),
      saveLiability: getIt<SaveLiabilityUseCase>(),
    ),
  );

  getIt.registerFactory<TimeFreedomBloc>(
    () => TimeFreedomBloc(
      timeProfileRepository: getIt<TimeProfileRepository>(),
      saveTimeProfile: getIt<SaveTimeProfileUseCase>(),
    ),
  );

  getIt.registerFactory<ExitSimulatorBloc>(
    () => ExitSimulatorBloc(
      scenarioEngine: getIt<ScenarioEngine>(),
      financialDataRepository: getIt<FinancialDataRepositoryImpl>(),
    ),
  );
}
