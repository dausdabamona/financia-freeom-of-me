/// Focus Domain - area of life to focus on today
///
/// The compass guides daily action towards freedom.
/// Each day has ONE focus area based on current situation.
///
/// Priority rules:
/// 1. If runway < 6 OR salary_dependency > 70% → A_FINANCIAL
/// 2. If emotional_pressure_high → C_PSYCHOLOGICAL
/// 3. Else → B_TIME_SYSTEM
enum FocusDomain {
  /// Financial improvements
  /// - Reduce spending
  /// - Increase income
  /// - Build emergency fund
  aFinancial('A_FINANCIAL', 'Keuangan', '💰'),

  /// Time and systems
  /// - Automation
  /// - Delegation
  /// - Efficiency
  /// - Building passive income systems
  bTimeSystem('B_TIME_SYSTEM', 'Waktu & Sistem', '⏰'),

  /// Mental and emotional
  /// - Stress management
  /// - Relationships
  /// - Mindset shifts
  /// - Dealing with fear/anxiety about money
  cPsychological('C_PSYCHOLOGICAL', 'Pikiran & Perasaan', '🧠');

  final String code;
  final String nameId;
  final String icon;

  const FocusDomain(this.code, this.nameId, this.icon);

  /// Parse from database string
  static FocusDomain fromCode(String code) {
    return FocusDomain.values.firstWhere(
      (domain) => domain.code == code,
      orElse: () => FocusDomain.aFinancial,
    );
  }

  /// Get color representation (hex code)
  String get colorHex {
    switch (this) {
      case FocusDomain.aFinancial:
        return '#4CAF50'; // Green
      case FocusDomain.bTimeSystem:
        return '#2196F3'; // Blue
      case FocusDomain.cPsychological:
        return '#9C27B0'; // Purple
    }
  }
}
