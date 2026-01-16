import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';

/// Exit Insight contains strategic metrics and emotional messages
/// for a given exit simulation scenario.
///
/// Philosophy: Numbers alone don't move people.
/// Stories and context do.
class ExitInsight extends Equatable {
  final String scenarioId;
  final String scenarioName;

  // Strategic metrics
  final int weeksSafe; // Weeks until WARNING zone
  final int weeksToCritical; // Weeks until CRITICAL zone
  final int weeksToZero; // Weeks until ZERO zone
  final int maxRunwayWeeks; // Total weeks until balance <= 0
  final ExitZone currentZone;

  // For comparison with baseline
  final int? weeksGainedVsBaseline;

  const ExitInsight({
    required this.scenarioId,
    required this.scenarioName,
    required this.weeksSafe,
    required this.weeksToCritical,
    required this.weeksToZero,
    required this.maxRunwayWeeks,
    required this.currentZone,
    this.weeksGainedVsBaseline,
  });

  /// Convert weeks to approximate months
  double get monthsSafe => weeksSafe / 4.33;
  double get monthsToCritical => weeksToCritical / 4.33;
  double get monthsToZero => weeksToZero / 4.33;
  double get maxRunwayMonths => maxRunwayWeeks / 4.33;

  /// Formatted runway
  String get runwayFormatted {
    if (maxRunwayWeeks >= 52) {
      final years = maxRunwayWeeks / 52;
      return '${years.toStringAsFixed(1)} tahun';
    } else if (maxRunwayWeeks >= 12) {
      return '${monthsToZero.toStringAsFixed(0)} bulan';
    } else {
      return '$maxRunwayWeeks minggu';
    }
  }

  /// Is this a critical situation requiring immediate attention?
  bool get isUrgent => weeksToCritical < 12;

  /// Is this situation relatively comfortable?
  bool get isComfortable => weeksSafe > 26; // 6+ months safe

  /// Generate the main emotional message
  /// Tone: Visioner, Menenangkan, Jujur
  String get emotionalMessage {
    if (maxRunwayWeeks >= 156) {
      // 3+ years
      return 'Kamu sudah membangun fondasi yang kuat. '
          'Runway-mu melebihi 3 tahun. '
          'Ini bukan keberuntungan—ini hasil dari keputusan-keputusan yang kamu buat.';
    }

    if (weeksSafe >= 52) {
      // 1+ year safe
      return 'Kamu memiliki jarak aman yang nyata—lebih dari setahun. '
          'Ini memberimu ruang untuk bernapas dan berpikir jernih '
          'tentang langkah selanjutnya.';
    }

    if (weeksSafe >= 26) {
      // 6+ months safe
      return 'Kamu aman sampai sekitar bulan ke-${monthsSafe.toStringAsFixed(0)}. '
          'Zona rawan mulai terasa di bulan ke-${monthsToCritical.toStringAsFixed(0)}. '
          'Waktu yang cukup untuk membangun sistem baru.';
    }

    if (weeksSafe >= 12) {
      // 3+ months safe
      return 'Kamu aman sampai sekitar minggu ke-$weeksSafe. '
          'Zona rawan mulai di minggu ke-$weeksToCritical. '
          'Sekarang adalah waktu yang tepat untuk memulai perubahan kecil.';
    }

    if (weeksSafe >= 4) {
      // 1+ month safe
      return 'Kamu memiliki buffer sekitar $weeksSafe minggu. '
          'Ini bukan situasi ideal, tapi juga bukan akhir. '
          'Fokus pada satu langkah konkret minggu ini.';
    }

    // Less than 1 month safe
    return 'Situasimu menuntut perhatian segera. '
        'Tapi ingat—setiap perubahan kecil punya dampak besar. '
        'Mulai dari yang paling memungkinkan hari ini.';
  }

  /// Generate visionary insight (looking forward)
  String get visionaryMessage {
    if (weeksGainedVsBaseline != null && weeksGainedVsBaseline! > 0) {
      if (weeksGainedVsBaseline! >= 26) {
        return 'Dengan perubahan ini, kamu memundurkan titik rawan '
            '${weeksGainedVsBaseline!} minggu—hampir setengah tahun. '
            'Bayangkan apa yang bisa kamu bangun dalam waktu itu.';
      }
      return 'Dengan satu perubahan kecil, kamu bisa memundurkan '
          'titik rawan $weeksGainedVsBaseline minggu. '
          'Setiap minggu yang kamu tambah, kamu sedang membeli kembali waktumu.';
    }

    if (isComfortable) {
      return 'Kamu sudah dalam posisi yang memungkinkan untuk berpikir '
          'tentang kebebasan, bukan sekadar bertahan. '
          'Pertanyaannya sekarang: sistem apa yang ingin kamu bangun?';
    }

    return 'Setiap langkah yang kamu ambil hari ini '
        'adalah investasi untuk kebebasanmu besok. '
        'Runway bukan tujuan—tapi jarak yang memberi ruang untuk membangun.';
  }

  /// Generate calming message
  String get calmingMessage {
    if (isUrgent) {
      return 'Melihat angka ini mungkin tidak nyaman. '
          'Tapi lebih baik tahu sekarang daripada terkejut nanti. '
          'Kamu sudah mengambil langkah pertama—melihat dengan jujur.';
    }

    return 'Kamu tidak sedang berlomba dengan siapa pun. '
        'Ini perjalananmu sendiri, dengan kecepatanmu sendiri. '
        'Yang penting adalah arah, bukan kecepatan.';
  }

  /// Generate realistic truth
  String get realisticMessage {
    if (maxRunwayWeeks <= 0) {
      return 'Di titik ini, sistem lama tidak lagi menopangmu. '
          'Dan di sinilah sistem baru mulai perlu dibangun. '
          'Ini bukan akhir—ini adalah titik transformasi.';
    }

    if (weeksToCritical <= 4) {
      return 'Kamu belum dalam zona aman. '
          'Tapi setiap orang yang sekarang bebas finansial, '
          'pernah berada di titik seperti ini. Mereka mulai dari sini.';
    }

    return 'Kamu belum sepenuhnya merdeka, '
        'tapi kamu sedang membangun jarak aman yang nyata. '
        'Itu sudah lebih dari kebanyakan orang.';
  }

  /// Get the appropriate focus domain for daily compass
  String get recommendedFocusDomain {
    if (weeksToCritical < 12) {
      return 'A_FINANCIAL';
    }
    if (weeksSafe > 26) {
      return 'B_TIME_SYSTEM';
    }
    return 'A_FINANCIAL';
  }

  @override
  List<Object?> get props => [
        scenarioId,
        scenarioName,
        weeksSafe,
        weeksToCritical,
        weeksToZero,
        maxRunwayWeeks,
        currentZone,
        weeksGainedVsBaseline,
      ];
}
