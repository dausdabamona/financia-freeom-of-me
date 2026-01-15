import 'package:get_it/get_it.dart';
import 'package:financial_freedom/core/database/app_database.dart';

final getIt = GetIt.instance;

/// Configure all dependencies for the application.
/// Called once at app startup.
Future<void> configureDependencies() async {
  // Database - Encrypted SQLite (Offline-First Core)
  final database = await AppDatabase.create();
  getIt.registerSingleton<AppDatabase>(database);

  // Repositories will be registered here
  // getIt.registerLazySingleton<FinancialRepository>(() => FinancialRepositoryImpl(getIt()));

  // Use Cases will be registered here
  // getIt.registerLazySingleton(() => GetBurnRate(getIt()));

  // BLoCs will be registered here
  // getIt.registerFactory(() => RealityEngineBloc(getIt()));
}
