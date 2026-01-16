import 'package:equatable/equatable.dart';

/// Time Profile entity - tracks how time is allocated
///
/// "Dari 168 jam hidupmu setiap minggu, berapa yang benar-benar milikmu?"
///
/// Time is the highest currency. This entity helps understand
/// how much of your life is truly yours.
class TimeProfile extends Equatable {
  final String id;

  /// Hours spent on work per week
  final double workHoursPerWeek;

  /// Hours spent on obligations (commute, chores, etc.) per week
  final double obligationHoursPerWeek;

  /// Hours of free choice per week
  final double freeHoursPerWeek;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeProfile({
    required this.id,
    required this.workHoursPerWeek,
    required this.obligationHoursPerWeek,
    required this.freeHoursPerWeek,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total hours in a week
  static const double totalHoursPerWeek = 168.0;

  /// Sleep hours (assumed 8 hours per day)
  static const double assumedSleepHours = 56.0;

  /// Calculated time freedom index (0.0 - 1.0)
  double get timeFreedomIndex => freeHoursPerWeek / totalHoursPerWeek;

  /// Time freedom percentage (0-100)
  double get timeFreedomPercent => timeFreedomIndex * 100;

  /// Hours bound to earning money or obligations
  double get boundHours => workHoursPerWeek + obligationHoursPerWeek;

  /// Check if time allocation is valid (doesn't exceed week hours minus sleep)
  bool get isValid {
    final awakeHours = totalHoursPerWeek - assumedSleepHours;
    return (workHoursPerWeek + obligationHoursPerWeek + freeHoursPerWeek) <= awakeHours + 10; // 10 hours tolerance
  }

  /// Get message about time situation
  String get situationMessage {
    if (timeFreedomPercent < 10) {
      return 'Waktumu sangat terikat. Ini prioritas untuk dibebaskan.';
    } else if (timeFreedomPercent < 20) {
      return 'Waktumu masih banyak terikat. Mari cari cara untuk mengklaim lebih banyak.';
    } else if (timeFreedomPercent < 30) {
      return 'Kamu punya waktu yang cukup untuk mulai membangun kebebasan.';
    } else if (timeFreedomPercent < 50) {
      return 'Keseimbangan yang baik. Terus jaga dan tingkatkan.';
    } else {
      return 'Waktu adalah milikmu. Gunakan dengan bijak untuk hal yang bermakna.';
    }
  }

  @override
  List<Object?> get props => [
        id,
        workHoursPerWeek,
        obligationHoursPerWeek,
        freeHoursPerWeek,
        createdAt,
        updatedAt,
      ];
}
