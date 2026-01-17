import 'package:equatable/equatable.dart';
import 'status_persetujuan.dart';

/// Jenis UP sesuai Permen KP 56/2024
enum JenisUp {
  /// UP Tunai - dibayarkan secara tunai
  tunai,

  /// UP Kartu Kredit Pemerintah (KKP)
  kkp,
}

extension JenisUpExtension on JenisUp {
  String get label {
    switch (this) {
      case JenisUp.tunai:
        return 'UP Tunai';
      case JenisUp.kkp:
        return 'UP Kartu Kredit Pemerintah';
    }
  }
}

/// Entity Uang Persediaan (UP) sesuai Permen KP 56/2024
///
/// UP adalah uang muka kerja dalam jumlah tertentu yang diberikan
/// kepada Bendahara Pengeluaran untuk membiayai kegiatan operasional
/// sehari-hari satuan kerja.
class UangPersediaan extends Equatable {
  final String id;
  final String nomorPengajuan;
  final DateTime tanggalPengajuan;
  final JenisUp jenisUp;
  final double jumlahPengajuan;
  final double jumlahDisetujui;
  final String tahunAnggaran;
  final String kodeSatker;
  final String namaSatker;
  final String kodeProgram;
  final String namaProgram;
  final String kodeKegiatan;
  final String namaKegiatan;
  final String kodeOutput;
  final String namaOutput;
  final String kodeAkun;
  final String namaAkun;
  final String uraianPenggunaan;
  final StatusPersetujuan status;
  final String? catatanPpk;
  final String? catatanBendahara;
  final String? catatanKpa;
  final String? alasanPenolakan;
  final DateTime? tanggalVerifikasi;
  final DateTime? tanggalPersetujuanKpa;
  final DateTime? tanggalPencairan;
  final DateTime? batasWaktuSpj;
  final double sisaUp;
  final double jumlahTerpakai;
  final double jumlahDipertanggungjawabkan;
  final bool isRevolvingFund; // UP dapat di-revolving
  final int urutanRevolving; // Urutan revolving ke-n
  final DateTime createdAt;
  final DateTime updatedAt;

  const UangPersediaan({
    required this.id,
    required this.nomorPengajuan,
    required this.tanggalPengajuan,
    required this.jenisUp,
    required this.jumlahPengajuan,
    this.jumlahDisetujui = 0,
    required this.tahunAnggaran,
    required this.kodeSatker,
    required this.namaSatker,
    required this.kodeProgram,
    required this.namaProgram,
    required this.kodeKegiatan,
    required this.namaKegiatan,
    required this.kodeOutput,
    required this.namaOutput,
    required this.kodeAkun,
    required this.namaAkun,
    required this.uraianPenggunaan,
    this.status = StatusPersetujuan.draft,
    this.catatanPpk,
    this.catatanBendahara,
    this.catatanKpa,
    this.alasanPenolakan,
    this.tanggalVerifikasi,
    this.tanggalPersetujuanKpa,
    this.tanggalPencairan,
    this.batasWaktuSpj,
    this.sisaUp = 0,
    this.jumlahTerpakai = 0,
    this.jumlahDipertanggungjawabkan = 0,
    this.isRevolvingFund = false,
    this.urutanRevolving = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Persentase penggunaan UP
  double get persentasePenggunaan {
    if (jumlahDisetujui == 0) return 0;
    return (jumlahTerpakai / jumlahDisetujui) * 100;
  }

  /// Persentase pertanggungjawaban
  double get persentaseSpj {
    if (jumlahTerpakai == 0) return 0;
    return (jumlahDipertanggungjawabkan / jumlahTerpakai) * 100;
  }

  /// Apakah sudah waktunya mengajukan revolving
  /// Sesuai Permen KP 56/2024, revolving dapat diajukan jika
  /// sudah dipertanggungjawabkan minimal 50%
  bool get canRevolving {
    return isRevolvingFund && persentaseSpj >= 50 && status == StatusPersetujuan.dicairkan;
  }

  /// Sisa hari untuk SPJ
  int get sisaHariSpj {
    if (batasWaktuSpj == null) return 0;
    return batasWaktuSpj!.difference(DateTime.now()).inDays;
  }

  /// Apakah mendekati batas waktu SPJ (kurang dari 7 hari)
  bool get isNearSpjDeadline => sisaHariSpj > 0 && sisaHariSpj <= 7;

  /// Apakah sudah melewati batas waktu SPJ
  bool get isOverdueSpj => sisaHariSpj < 0 && status != StatusPersetujuan.selesai;

  UangPersediaan copyWith({
    String? id,
    String? nomorPengajuan,
    DateTime? tanggalPengajuan,
    JenisUp? jenisUp,
    double? jumlahPengajuan,
    double? jumlahDisetujui,
    String? tahunAnggaran,
    String? kodeSatker,
    String? namaSatker,
    String? kodeProgram,
    String? namaProgram,
    String? kodeKegiatan,
    String? namaKegiatan,
    String? kodeOutput,
    String? namaOutput,
    String? kodeAkun,
    String? namaAkun,
    String? uraianPenggunaan,
    StatusPersetujuan? status,
    String? catatanPpk,
    String? catatanBendahara,
    String? catatanKpa,
    String? alasanPenolakan,
    DateTime? tanggalVerifikasi,
    DateTime? tanggalPersetujuanKpa,
    DateTime? tanggalPencairan,
    DateTime? batasWaktuSpj,
    double? sisaUp,
    double? jumlahTerpakai,
    double? jumlahDipertanggungjawabkan,
    bool? isRevolvingFund,
    int? urutanRevolving,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UangPersediaan(
      id: id ?? this.id,
      nomorPengajuan: nomorPengajuan ?? this.nomorPengajuan,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      jenisUp: jenisUp ?? this.jenisUp,
      jumlahPengajuan: jumlahPengajuan ?? this.jumlahPengajuan,
      jumlahDisetujui: jumlahDisetujui ?? this.jumlahDisetujui,
      tahunAnggaran: tahunAnggaran ?? this.tahunAnggaran,
      kodeSatker: kodeSatker ?? this.kodeSatker,
      namaSatker: namaSatker ?? this.namaSatker,
      kodeProgram: kodeProgram ?? this.kodeProgram,
      namaProgram: namaProgram ?? this.namaProgram,
      kodeKegiatan: kodeKegiatan ?? this.kodeKegiatan,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      kodeOutput: kodeOutput ?? this.kodeOutput,
      namaOutput: namaOutput ?? this.namaOutput,
      kodeAkun: kodeAkun ?? this.kodeAkun,
      namaAkun: namaAkun ?? this.namaAkun,
      uraianPenggunaan: uraianPenggunaan ?? this.uraianPenggunaan,
      status: status ?? this.status,
      catatanPpk: catatanPpk ?? this.catatanPpk,
      catatanBendahara: catatanBendahara ?? this.catatanBendahara,
      catatanKpa: catatanKpa ?? this.catatanKpa,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      tanggalPersetujuanKpa: tanggalPersetujuanKpa ?? this.tanggalPersetujuanKpa,
      tanggalPencairan: tanggalPencairan ?? this.tanggalPencairan,
      batasWaktuSpj: batasWaktuSpj ?? this.batasWaktuSpj,
      sisaUp: sisaUp ?? this.sisaUp,
      jumlahTerpakai: jumlahTerpakai ?? this.jumlahTerpakai,
      jumlahDipertanggungjawabkan: jumlahDipertanggungjawabkan ?? this.jumlahDipertanggungjawabkan,
      isRevolvingFund: isRevolvingFund ?? this.isRevolvingFund,
      urutanRevolving: urutanRevolving ?? this.urutanRevolving,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nomorPengajuan,
        tanggalPengajuan,
        jenisUp,
        jumlahPengajuan,
        jumlahDisetujui,
        tahunAnggaran,
        kodeSatker,
        namaSatker,
        kodeProgram,
        namaProgram,
        kodeKegiatan,
        namaKegiatan,
        kodeOutput,
        namaOutput,
        kodeAkun,
        namaAkun,
        uraianPenggunaan,
        status,
        catatanPpk,
        catatanBendahara,
        catatanKpa,
        alasanPenolakan,
        tanggalVerifikasi,
        tanggalPersetujuanKpa,
        tanggalPencairan,
        batasWaktuSpj,
        sisaUp,
        jumlahTerpakai,
        jumlahDipertanggungjawabkan,
        isRevolvingFund,
        urutanRevolving,
        createdAt,
        updatedAt,
      ];
}
