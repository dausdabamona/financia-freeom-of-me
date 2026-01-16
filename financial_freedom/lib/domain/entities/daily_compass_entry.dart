import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/focus_domain.dart';

/// Daily Compass Entry - one small step each day
///
/// The compass guides daily action towards freedom.
/// Each day has ONE focus area and ONE actionable message.
///
/// Tone: Akrab, Jujur, Navigator tegas + sahabat + mentor
class DailyCompassEntry extends Equatable {
  final String id;
  final DateTime date;
  final FocusDomain focusDomain;
  final String message;
  final bool completed;
  final String? notes;

  const DailyCompassEntry({
    required this.id,
    required this.date,
    required this.focusDomain,
    required this.message,
    this.completed = false,
    this.notes,
  });

  /// Create a copy with updated fields
  DailyCompassEntry copyWith({
    String? id,
    DateTime? date,
    FocusDomain? focusDomain,
    String? message,
    bool? completed,
    String? notes,
  }) {
    return DailyCompassEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      focusDomain: focusDomain ?? this.focusDomain,
      message: message ?? this.message,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  /// Mark as completed
  DailyCompassEntry markCompleted() => copyWith(completed: true);

  @override
  List<Object?> get props => [
        id,
        date,
        focusDomain,
        message,
        completed,
        notes,
      ];
}

/// Compass message templates for each domain and situation
class CompassMessages {
  CompassMessages._();

  /// A_FINANCIAL domain messages - when runway is low or dependency is high
  static const List<String> financialMessages = [
    'Hari ini, satu langkah kecil: kurangi satu pengeluaran yang tidak menambah kebebasanmu.',
    'Tinjau langganan-mu. Ada yang bisa di-cancel? Setiap rupiah menambah runway-mu.',
    'Cari satu cara untuk menambah pemasukan bulan ini. Skill apa yang bisa kamu jual?',
    'Buat daftar 3 pengeluaran terbesar-mu. Pilih satu untuk dikurangi.',
    'Hari ini, fokus di emergency fund. Tambahkan berapa pun yang kamu bisa.',
    'Evaluasi satu kebiasaan yang menguras uang tapi tidak memberimu kebahagiaan.',
    'Negosiasi satu tagihan atau langganan. Sering berhasil kalau kamu minta.',
    'Jual satu barang yang tidak terpakai. Tambahkan hasilnya ke runway-mu.',
  ];

  /// B_TIME_SYSTEM domain messages - when financial situation is stable
  static const List<String> timeSystemMessages = [
    'Identifikasi satu tugas yang bisa di-automate. Waktumu lebih berharga dari uang.',
    'Delegasikan satu hal hari ini. Tidak semua harus dikerjakan sendiri.',
    'Riset satu sumber passive income. Mulai dari yang paling cocok dengan skill-mu.',
    'Bangun satu sistem yang bekerja untukmu, bahkan saat kamu tidur.',
    'Audit waktu-mu hari ini. Di mana waktu terbuang? Bagaimana bisa diklaim kembali?',
    'Investasikan 30 menit untuk belajar skill yang bisa menghasilkan tanpa kamu hadir.',
    'Setup satu hal yang berjalan otomatis: investasi, tabungan, atau pembayaran.',
    'Hari ini, fokus pada aset yang menghasilkan. Bukan kerja keras, tapi kerja cerdas.',
  ];

  /// C_PSYCHOLOGICAL domain messages - for mental and emotional focus
  static const List<String> psychologicalMessages = [
    'Istirahat sejenak. Perjalanan ke kebebasan butuh energi. Jaga dirimu.',
    'Tulis satu hal yang membuatmu stres tentang uang. Kemudian, lepaskan.',
    'Rayakan progress kecil hari ini. Kamu sudah lebih baik dari kemarin.',
    'Bicara dengan seseorang tentang goals finansialmu. Berbagi meringankan beban.',
    'Journaling: Apa ketakutan terbesarmu tentang uang? Tulis, lalu hadapi.',
    'Gratitude: Tulis 3 hal yang sudah kamu miliki. Kebebasan dimulai dari rasa cukup.',
    'Hari ini, jangan bandingkan dirimu dengan orang lain. Ini perjalananmu sendiri.',
    'Refleksi: Kenapa kamu ingin bebas finansial? Ingat "why"-mu.',
  ];

  /// Get appropriate message based on domain and situation
  static String getMessageFor({
    required FocusDomain domain,
    required double runwayMonths,
    required double salaryDependencyRatio,
  }) {
    final messages = switch (domain) {
      FocusDomain.aFinancial => financialMessages,
      FocusDomain.bTimeSystem => timeSystemMessages,
      FocusDomain.cPsychological => psychologicalMessages,
    };

    // Simple selection based on date for variety
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final index = dayOfYear % messages.length;

    return messages[index];
  }
}
