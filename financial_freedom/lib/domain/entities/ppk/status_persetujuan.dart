/// Status persetujuan UP/TUP sesuai Permen KP 56/2024
enum StatusPersetujuan {
  /// Draft - belum diajukan
  draft,

  /// Diajukan ke Bendahara Pengeluaran
  diajukan,

  /// Diverifikasi oleh Bendahara Pengeluaran
  diverifikasi,

  /// Menunggu persetujuan KPA
  menungguPersetujuanKpa,

  /// Disetujui oleh KPA
  disetujuiKpa,

  /// Ditolak
  ditolak,

  /// Dalam proses pencairan
  prosesPencairan,

  /// Sudah dicairkan
  dicairkan,

  /// Dalam proses pertanggungjawaban
  prosesSpj,

  /// Sudah dipertanggungjawabkan (SPJ selesai)
  selesai,
}

extension StatusPersetujuanExtension on StatusPersetujuan {
  String get label {
    switch (this) {
      case StatusPersetujuan.draft:
        return 'Draft';
      case StatusPersetujuan.diajukan:
        return 'Diajukan';
      case StatusPersetujuan.diverifikasi:
        return 'Diverifikasi';
      case StatusPersetujuan.menungguPersetujuanKpa:
        return 'Menunggu Persetujuan KPA';
      case StatusPersetujuan.disetujuiKpa:
        return 'Disetujui KPA';
      case StatusPersetujuan.ditolak:
        return 'Ditolak';
      case StatusPersetujuan.prosesPencairan:
        return 'Proses Pencairan';
      case StatusPersetujuan.dicairkan:
        return 'Dicairkan';
      case StatusPersetujuan.prosesSpj:
        return 'Proses SPJ';
      case StatusPersetujuan.selesai:
        return 'Selesai';
    }
  }

  String get deskripsi {
    switch (this) {
      case StatusPersetujuan.draft:
        return 'Pengajuan masih dalam draft dan belum diajukan';
      case StatusPersetujuan.diajukan:
        return 'Pengajuan telah diajukan ke Bendahara Pengeluaran';
      case StatusPersetujuan.diverifikasi:
        return 'Pengajuan telah diverifikasi oleh Bendahara Pengeluaran';
      case StatusPersetujuan.menungguPersetujuanKpa:
        return 'Pengajuan menunggu persetujuan dari KPA';
      case StatusPersetujuan.disetujuiKpa:
        return 'Pengajuan telah disetujui oleh KPA';
      case StatusPersetujuan.ditolak:
        return 'Pengajuan ditolak';
      case StatusPersetujuan.prosesPencairan:
        return 'Dana dalam proses pencairan';
      case StatusPersetujuan.dicairkan:
        return 'Dana telah dicairkan';
      case StatusPersetujuan.prosesSpj:
        return 'Dalam proses pertanggungjawaban (SPJ)';
      case StatusPersetujuan.selesai:
        return 'Pengajuan telah selesai dan dipertanggungjawabkan';
    }
  }

  bool get canEdit => this == StatusPersetujuan.draft || this == StatusPersetujuan.ditolak;
  bool get canSubmit => this == StatusPersetujuan.draft;
  bool get canVerify => this == StatusPersetujuan.diajukan;
  bool get canApprove => this == StatusPersetujuan.diverifikasi || this == StatusPersetujuan.menungguPersetujuanKpa;
  bool get canDisburse => this == StatusPersetujuan.disetujuiKpa;
  bool get needsSpj => this == StatusPersetujuan.dicairkan;
}
