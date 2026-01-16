import 'package:drift/drift.dart';

/// Time Profiles table - tracks weekly time allocation
///
/// "Dari 168 jam hidupmu setiap minggu, berapa yang benar-benar milikmu?"
///
/// This tracks how time is distributed:
/// - Work hours: Time spent earning money
/// - Obligation hours: Commute, chores, responsibilities
/// - Free hours: Time of true choice
class TimeProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Hours spent on work per week
  RealColumn get workHoursPerWeek => real().withDefault(const Constant(40.0))();

  /// Hours spent on obligations per week
  RealColumn get obligationHoursPerWeek => real().withDefault(const Constant(20.0))();

  /// Hours of free choice per week
  RealColumn get freeHoursPerWeek => real().withDefault(const Constant(52.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
