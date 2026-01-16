import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';
import 'package:financial_freedom/domain/entities/focus_domain.dart';

/// Mapper for DailyCompassEntry between domain and database layers
class DailyCompassMapper {
  /// Convert database model to domain entity
  static DailyCompassEntry toDomain(DailyCompassData dbModel) {
    return DailyCompassEntry(
      id: dbModel.id.toString(),
      date: dbModel.date,
      focusDomain: FocusDomain.fromCode(dbModel.focusDomain),
      message: dbModel.message,
      completed: dbModel.completed,
      notes: dbModel.notes,
    );
  }

  /// Convert domain entity to database companion for insert
  static DailyCompassCompanion toCompanion(DailyCompassEntry entity) {
    return DailyCompassCompanion(
      date: Value(entity.date),
      focusDomain: Value(entity.focusDomain.code),
      message: Value(entity.message),
      completed: Value(entity.completed),
      notes: Value(entity.notes),
    );
  }

  /// Convert domain entity to database model for update
  static DailyCompassData toDbModel(DailyCompassEntry entity) {
    return DailyCompassData(
      id: int.parse(entity.id),
      date: entity.date,
      focusDomain: entity.focusDomain.code,
      message: entity.message,
      completed: entity.completed,
      notes: entity.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
