/// Freedom Phase - represents the stage of financial independence journey
///
/// This is the core concept of the Financial Freedom Compass.
/// Each phase has specific characteristics and guidance.
enum FreedomPhase {
  /// BOUND: Still heavily dependent on active income
  /// - Runway < 6 months OR salary dependency > 70%
  /// - Priority: Build emergency fund, reduce expenses
  bound('BOUND', 'Terikat', 'Masih terikat pada gaji aktif'),

  /// TRANSITION: Building passive income, reducing dependency
  /// - Runway 6-18 months AND salary dependency 30-70%
  /// - Priority: Diversify income, build passive streams
  transition('TRANSITION', 'Transisi', 'Sedang membangun jalan keluar'),

  /// INDEPENDENT: Can survive without salary for extended period
  /// - Runway > 18 months AND salary dependency < 30%
  /// - Priority: Optimize passive income, increase assets
  independent('INDEPENDENT', 'Mandiri', 'Bisa bertahan lama tanpa gaji'),

  /// OPTIONAL: Work is optional, passive income covers expenses
  /// - Passive income >= burn rate
  /// - Priority: Enjoy freedom, give back
  optional('OPTIONAL', 'Opsional', 'Bekerja adalah pilihan'),

  /// FREE: True freedom - time and money abundance
  /// - Passive income >= burn rate AND time freedom index > 0.5
  /// - Priority: Live fully, help others reach freedom
  free('FREE', 'Bebas', 'Kebebasan penuh - waktu dan uang');

  final String code;
  final String nameId;
  final String description;

  const FreedomPhase(this.code, this.nameId, this.description);

  /// Parse from database string
  static FreedomPhase fromCode(String code) {
    return FreedomPhase.values.firstWhere(
      (phase) => phase.code == code,
      orElse: () => FreedomPhase.bound,
    );
  }

  /// Get encouraging message for the user
  String get message {
    switch (this) {
      case FreedomPhase.bound:
        return 'Kita mulai dari sini. Setiap langkah kecil mendekatkanmu pada kebebasan.';
      case FreedomPhase.transition:
        return 'Kamu sedang dalam perjalanan. Terus bangun fondasi kebebasanmu.';
      case FreedomPhase.independent:
        return 'Bagus! Kamu punya runway yang sehat. Fokus membangun passive income.';
      case FreedomPhase.optional:
        return 'Luar biasa! Passive income-mu sudah menutup kebutuhan. Nikmati pilihanmu.';
      case FreedomPhase.free:
        return 'Kamu sudah bebas. Waktumu adalah milikmu sendiri.';
    }
  }

  /// Get color representation (hex code)
  String get colorHex {
    switch (this) {
      case FreedomPhase.bound:
        return '#E53935'; // Red
      case FreedomPhase.transition:
        return '#FB8C00'; // Orange
      case FreedomPhase.independent:
        return '#FDD835'; // Yellow
      case FreedomPhase.optional:
        return '#7CB342'; // Light Green
      case FreedomPhase.free:
        return '#43A047'; // Green
    }
  }
}
