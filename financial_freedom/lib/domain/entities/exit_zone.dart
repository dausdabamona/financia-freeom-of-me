import 'package:flutter/material.dart';

/// Exit Zone represents the financial safety level for a given week
///
/// Philosophy: This is not about fear, but about awareness.
/// Each zone tells you where you stand, not to scare you,
/// but to show you where to focus.
enum ExitZone {
  /// SAFE: ending_balance > 3x weekly_burn
  /// "Kamu dalam zona aman. Sistem lama masih menopangmu."
  safe,

  /// WARNING: 1x-3x weekly_burn
  /// "Zona peringatan. Bukan panik, tapi waktunya lebih waspada."
  warning,

  /// CRITICAL: < 1x weekly_burn
  /// "Zona kritis. Saatnya fokus pada langkah konkret."
  critical,

  /// ZERO: <= 0
  /// "Di titik ini, sistem lama tidak lagi menopangmu.
  /// Dan di sinilah sistem baru mulai perlu dibangun."
  zero,
}

extension ExitZoneX on ExitZone {
  String get nameId {
    switch (this) {
      case ExitZone.safe:
        return 'Aman';
      case ExitZone.warning:
        return 'Waspada';
      case ExitZone.critical:
        return 'Kritis';
      case ExitZone.zero:
        return 'Titik Nol';
    }
  }

  String get description {
    switch (this) {
      case ExitZone.safe:
        return 'Kamu dalam zona aman. Sistem lama masih menopangmu dengan baik.';
      case ExitZone.warning:
        return 'Zona peringatan. Bukan untuk panik, tapi waktunya lebih waspada.';
      case ExitZone.critical:
        return 'Zona kritis. Saatnya fokus pada langkah konkret.';
      case ExitZone.zero:
        return 'Di titik ini, sistem lama tidak lagi menopangmu. '
            'Dan di sinilah sistem baru mulai perlu dibangun.';
    }
  }

  Color get color {
    switch (this) {
      case ExitZone.safe:
        return Colors.green;
      case ExitZone.warning:
        return Colors.orange;
      case ExitZone.critical:
        return Colors.deepOrange;
      case ExitZone.zero:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ExitZone.safe:
        return Icons.shield;
      case ExitZone.warning:
        return Icons.warning_amber;
      case ExitZone.critical:
        return Icons.error_outline;
      case ExitZone.zero:
        return Icons.flag;
    }
  }

  /// Convert to/from database string
  String get dbValue => name;

  static ExitZone fromDbValue(String value) {
    return ExitZone.values.firstWhere(
      (z) => z.name == value,
      orElse: () => ExitZone.safe,
    );
  }
}
