import 'package:drift/drift.dart';

/// Freedom Phase - the stage of financial independence journey
///
/// BOUND: Still heavily dependent on active income
/// TRANSITION: Building passive income, reducing dependency
/// INDEPENDENT: Can survive without salary for extended period
/// OPTIONAL: Work is optional, passive income covers expenses
/// FREE: True freedom - time and money abundance
class FreedomPhaseType {
  static const String bound = 'BOUND';
  static const String transition = 'TRANSITION';
  static const String independent = 'INDEPENDENT';
  static const String optional = 'OPTIONAL';
  static const String free = 'FREE';

  static const List<String> values = [
    bound,
    transition,
    independent,
    optional,
    free,
  ];

  /// Human-readable descriptions in Indonesian
  static String getDescription(String phase) {
    switch (phase) {
      case bound:
        return 'Masih terikat pada gaji aktif';
      case transition:
        return 'Sedang membangun jalan keluar';
      case independent:
        return 'Bisa bertahan lama tanpa gaji';
      case optional:
        return 'Bekerja adalah pilihan, bukan keharusan';
      case free:
        return 'Kebebasan penuh - waktu dan uang';
      default:
        return 'Unknown';
    }
  }

  /// Encouraging message for each phase
  static String getMessage(String phase) {
    switch (phase) {
      case bound:
        return 'Kita mulai dari sini. Setiap langkah kecil mendekatkanmu pada kebebasan.';
      case transition:
        return 'Kamu sedang dalam perjalanan. Terus bangun fondasi kebebasanmu.';
      case independent:
        return 'Bagus! Kamu punya runway yang sehat. Fokus membangun passive income.';
      case optional:
        return 'Luar biasa! Passive income-mu sudah menutup kebutuhan. Nikmati pilihanmu.';
      case free:
        return 'Kamu sudah bebas. Waktumu adalah milikmu sendiri.';
      default:
        return '';
    }
  }
}

/// Financial Snapshots table - daily history of financial state
///
/// This captures the reality at a point in time.
/// Used to track progress over weeks, months, years.
class FinancialSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Date of snapshot (one per day max)
  DateTimeColumn get date => dateTime().unique()();

  /// Monthly burn rate (expenses + debt payments + buffer)
  RealColumn get burnRate => real()();

  /// Runway in months (liquid assets / burn rate)
  RealColumn get runwayMonths => real()();

  /// Salary dependency ratio (0.0 - 1.0)
  /// 1.0 = 100% dependent on salary
  /// 0.0 = 100% passive/business income
  RealColumn get salaryDependencyRatio => real()();

  /// Time freedom index (0.0 - 1.0)
  /// free_hours_per_week / 168
  RealColumn get timeFreedomIndex => real()();

  /// Current freedom phase
  TextColumn get freedomPhase => text().withLength(min: 1, max: 20)();

  /// Total liquid assets at snapshot time
  RealColumn get totalLiquidAssets => real()();

  /// Total passive income at snapshot time
  RealColumn get totalPassiveIncome => real()();

  /// Total monthly income at snapshot time
  RealColumn get totalMonthlyIncome => real()();

  /// Net worth at snapshot time
  RealColumn get netWorth => real()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
