/// Domain layer exports
///
/// Contains pure business logic:
/// - Entities (domain models)
/// - Enums (FreedomPhase, FocusDomain, etc.)
/// - Repository contracts
/// - Use cases
library domain;

// Entities
export 'entities/account.dart';
export 'entities/asset.dart';
export 'entities/daily_compass_entry.dart';
export 'entities/financial_snapshot.dart';
export 'entities/focus_domain.dart';
export 'entities/freedom_phase.dart';
export 'entities/liability.dart';
export 'entities/monthly_baseline.dart';
export 'entities/transaction.dart';

// Repositories
export 'repositories/account_repository.dart';
export 'repositories/asset_repository.dart';
export 'repositories/daily_compass_repository.dart';
export 'repositories/financial_repository.dart';
export 'repositories/liability_repository.dart';
export 'repositories/monthly_baseline_repository.dart';
export 'repositories/transaction_repository.dart';

// Use Cases
export 'usecases/get_financial_reality.dart';
export 'usecases/generate_daily_snapshot.dart';
