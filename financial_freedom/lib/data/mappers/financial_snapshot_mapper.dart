import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart' as domain;
import 'package:financial_freedom/domain/entities/freedom_phase.dart';

/// Mapper for FinancialSnapshot between domain and database layers
class FinancialSnapshotMapper {
  /// Convert database model to domain entity
  static domain.FinancialSnapshot toDomain(FinancialSnapshot dbModel) {
    return domain.FinancialSnapshot(
      id: dbModel.id.toString(),
      date: dbModel.date,
      burnRate: dbModel.burnRate,
      runwayMonths: dbModel.runwayMonths,
      salaryDependencyRatio: dbModel.salaryDependencyRatio,
      timeFreedomIndex: dbModel.timeFreedomIndex,
      freedomPhase: FreedomPhase.fromCode(dbModel.freedomPhase),
      totalLiquidAssets: dbModel.totalLiquidAssets,
      totalPassiveIncome: dbModel.totalPassiveIncome,
      totalMonthlyIncome: dbModel.totalMonthlyIncome,
      netWorth: dbModel.netWorth,
    );
  }

  /// Convert domain entity to database companion for insert
  static FinancialSnapshotsCompanion toCompanion(domain.FinancialSnapshot entity) {
    return FinancialSnapshotsCompanion(
      date: Value(entity.date),
      burnRate: Value(entity.burnRate),
      runwayMonths: Value(entity.runwayMonths),
      salaryDependencyRatio: Value(entity.salaryDependencyRatio),
      timeFreedomIndex: Value(entity.timeFreedomIndex),
      freedomPhase: Value(entity.freedomPhase.code),
      totalLiquidAssets: Value(entity.totalLiquidAssets),
      totalPassiveIncome: Value(entity.totalPassiveIncome),
      totalMonthlyIncome: Value(entity.totalMonthlyIncome),
      netWorth: Value(entity.netWorth),
    );
  }

  /// Convert domain entity to database model for update
  static FinancialSnapshot toDbModel(domain.FinancialSnapshot entity) {
    return FinancialSnapshot(
      id: int.parse(entity.id),
      date: entity.date,
      burnRate: entity.burnRate,
      runwayMonths: entity.runwayMonths,
      salaryDependencyRatio: entity.salaryDependencyRatio,
      timeFreedomIndex: entity.timeFreedomIndex,
      freedomPhase: entity.freedomPhase.code,
      totalLiquidAssets: entity.totalLiquidAssets,
      totalPassiveIncome: entity.totalPassiveIncome,
      totalMonthlyIncome: entity.totalMonthlyIncome,
      netWorth: entity.netWorth,
      createdAt: DateTime.now(),
    );
  }
}
