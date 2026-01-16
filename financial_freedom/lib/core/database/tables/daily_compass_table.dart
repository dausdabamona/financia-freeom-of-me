import 'package:drift/drift.dart';

/// Focus Domain - area of life to focus on today
///
/// A_FINANCIAL: Financial improvements (reduce spending, increase income)
/// B_TIME_SYSTEM: Time and systems (automation, delegation, efficiency)
/// C_PSYCHOLOGICAL: Mental and emotional (stress, relationships, mindset)
class FocusDomainType {
  static const String aFinancial = 'A_FINANCIAL';
  static const String bTimeSystem = 'B_TIME_SYSTEM';
  static const String cPsychological = 'C_PSYCHOLOGICAL';

  static const List<String> values = [
    aFinancial,
    bTimeSystem,
    cPsychological,
  ];

  /// Human-readable names in Indonesian
  static String getName(String domain) {
    switch (domain) {
      case aFinancial:
        return 'Keuangan';
      case bTimeSystem:
        return 'Waktu & Sistem';
      case cPsychological:
        return 'Pikiran & Perasaan';
      default:
        return 'Unknown';
    }
  }

  /// Icon suggestion for each domain
  static String getIcon(String domain) {
    switch (domain) {
      case aFinancial:
        return '💰';
      case bTimeSystem:
        return '⏰';
      case cPsychological:
        return '🧠';
      default:
        return '📍';
    }
  }
}

/// Daily Compass table - one small step each day
///
/// The compass guides daily action towards freedom.
/// Each day has ONE focus area and ONE actionable message.
///
/// Priority rules:
/// 1. If runway < 6 OR salary_dependency > 70% → A_FINANCIAL
/// 2. If emotional_pressure_high → C_PSYCHOLOGICAL
/// 3. Else → B_TIME_SYSTEM
class DailyCompass extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Date of compass entry (one per day max)
  DateTimeColumn get date => dateTime().unique()();

  /// Focus domain for today
  TextColumn get focusDomain => text().withLength(min: 1, max: 20)();

  /// The small step message for today
  /// Written in friendly, honest, mentor-like tone
  TextColumn get message => text()();

  /// Whether the user completed this step
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// Optional notes from user
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
