/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App information
  static const String appName = 'Financial Freedom';
  static const String appVersion = '1.0.0';

  /// Database
  static const String databaseName = 'financial_freedom.db';
  static const int databaseVersion = 1;

  /// Backup
  static const String backupFileExtension = '.ffbackup';
  static const String backupEncryptionAlgorithm = 'AES-256-GCM';

  /// Financial calculations
  static const int daysInMonth = 30;
  static const int monthsInYear = 12;
}

/// Freedom phases based on salary dependency
enum FreedomPhase {
  /// 80-100% salary dependent - Just starting
  trapped('Trapped', 'Masih sangat bergantung pada gaji'),

  /// 60-80% salary dependent - Building awareness
  awakening('Awakening', 'Mulai membangun sumber lain'),

  /// 40-60% salary dependent - Making progress
  building('Building', 'Membangun fondasi kebebasan'),

  /// 20-40% salary dependent - Almost there
  emerging('Emerging', 'Hampir mencapai kebebasan'),

  /// 0-20% salary dependent - Financially free
  free('Free', 'Kedaulatan waktu tercapai');

  final String name;
  final String description;

  const FreedomPhase(this.name, this.description);

  /// Determine phase based on salary dependency percentage
  static FreedomPhase fromSalaryDependency(double percentage) {
    if (percentage >= 80) return FreedomPhase.trapped;
    if (percentage >= 60) return FreedomPhase.awakening;
    if (percentage >= 40) return FreedomPhase.building;
    if (percentage >= 20) return FreedomPhase.emerging;
    return FreedomPhase.free;
  }
}
