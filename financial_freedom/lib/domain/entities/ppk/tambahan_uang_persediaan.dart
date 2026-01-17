import 'package:equatable/equatable.dart';
import 'status_persetujuan.dart';

/// Alasan pengajuan TUP sesuai Permen KP 56/2024
enum AlasanTup {
  /// Kegiatan yang bersifat mendesak
  kegiatanMendesak,

  /// Pengeluaran UP mengalami kekurangan
  kekuranganUp,

  /// Kegiatan di lokasi terpencil
  lokasiTerpencil,

  /// Kegiatan yang tidak dapat ditunda
  tidakDapatDitunda,

  /// Penyelenggaraan kunjungan kerja/rapat koordinasi
  kunjunganKerja,

  /// Kebutuhan operasional lainnya yang mendesak
  operasionalMendesak,
}

extension AlasanTupExtension on AlasanTup {
  String get label {
    switch (this) {
      case AlasanTup.kegiatanMendesak:
        return 'Kegiatan yang Bersifat Mendesak';
      case AlasanTup.kekuranganUp:
        return 'Pengeluaran UP Mengalami Kekurangan';
      case AlasanTup.lokasiTerpencil:
        return 'Kegiatan di Lokasi Terpencil';
      case AlasanTup.tidakDapatDitunda:
        return 'Kegiatan yang Tidak Dapat Ditunda';
      case AlasanTup.kunjunganKerja:
        return 'Kunjungan Kerja/Rapat Koordinasi';
      case AlasanTup.operasionalMendesak:
        return 'Kebutuhan Operasional Mendesak Lainnya';
    }
  }

  String get deskripsi {
    switch (this) {
      case AlasanTup.kegiatanMendesak:
        return 'Kegiatan yang memerlukan penanganan segera dan tidak dapat ditunda';
      case AlasanTup.kekuranganUp:
        return 'UP yang tersedia tidak mencukupi kebutuhan operasional';
      case AlasanTup.lokasiTerpencil:
        return 'Kegiatan dilaksanakan di lokasi yang jauh dari perbankan';
      case AlasanTup.tidakDapatDitunda:
        return 'Kegiatan yang harus dilaksanakan sesuai jadwal dan tidak dapat diundur';
      case AlasanTup.kunjunganKerja:
        return 'Penyelenggaraan kunjungan kerja pimpinan atau rapat koordinasi';
      case AlasanTup.operasionalMendesak:
        return 'Kebutuhan operasional kantor yang bersifat mendesak dan tidak terduga';
    }
  }
}

/// Entity Tambahan Uang Persediaan (TUP) sesuai Permen KP 56/2024
///
/// TUP adalah uang muka yang diberikan kepada Bendahara Pengeluaran
/// untuk kebutuhan yang sangat mendesak dalam 1 (satu) bulan melebihi
/// pagu UP yang telah ditetapkan.
class TambahanUangPersediaan extends Equatable {
  final String id;
  final String nomorPengajuan;
  final DateTime tanggalPengajuan;
  final double jumlahPengajuan;
  final double jumlahDisetujui;
  final AlasanTup alasanPengajuan;
  final String uraianAlasan;
  final String rincianKebutuhan;
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
  final StatusPersetujuan status;
  final String? catatanPpk;
  final String? catatanBendahara;
  final String? catatanKpa;
  final String? alasanPenolakan;
  final DateTime? tanggalVerifikasi;
  final DateTime? tanggalPersetujuanKpa;
  final DateTime? tanggalPencairan;
  final DateTime batasWaktuSpj; // TUP wajib di-SPJ-kan dalam 1 bulan
  final double jumlahTerpakai;
  final double jumlahDipertanggungjawabkan;
  final double jumlahDikembalikan; // Sisa TUP yang dikembalikan ke kas negara
  final bool isSudahDikembalikan; // Sisa sudah disetor ke kas negara
  final String? nomorBuktiSetor; // Nomor bukti setor sisa TUP
  final DateTime? tanggalSetor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TambahanUangPersediaan({
    required this.id,
    required this.nomorPengajuan,
    required this.tanggalPengajuan,
    required this.jumlahPengajuan,
    this.jumlahDisetujui = 0,
    required this.alasanPengajuan,
    required this.uraianAlasan,
    required this.rincianKebutuhan,
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
    this.status = StatusPersetujuan.draft,
    this.catatanPpk,
    this.catatanBendahara,
    this.catatanKpa,
    this.alasanPenolakan,
    this.tanggalVerifikasi,
    this.tanggalPersetujuanKpa,
    this.tanggalPencairan,
    required this.batasWaktuSpj,
    this.jumlahTerpakai = 0,
    this.jumlahDipertanggungjawabkan = 0,
    this.jumlahDikembalikan = 0,
    this.isSudahDikembalikan = false,
    this.nomorBuktiSetor,
    this.tanggalSetor,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Sisa TUP yang belum digunakan
  double get sisaTup {
    return jumlahDisetujui - jumlahTerpakai;
  }

  /// Persentase penggunaan TUP
  double get persentasePenggunaan {
    if (jumlahDisetujui == 0) return 0;
    return (jumlahTerpakai / jumlahDisetujui) * 100;
  }

  /// Persentase pertanggungjawaban
  double get persentaseSpj {
    if (jumlahTerpakai == 0) return 0;
    return (jumlahDipertanggungjawabkan / jumlahTerpakai) * 100;
  }

  /// Sisa hari untuk SPJ (TUP wajib di-SPJ-kan dalam 1 bulan)
  int get sisaHariSpj {
    return batasWaktuSpj.difference(DateTime.now()).inDays;
  }

  /// Apakah mendekati batas waktu SPJ (kurang dari 7 hari)
  bool get isNearSpjDeadline => sisaHariSpj > 0 && sisaHariSpj <= 7;

  /// Apakah sudah melewati batas waktu SPJ
  bool get isOverdueSpj => sisaHariSpj < 0 && status != StatusPersetujuan.selesai;

  /// Apakah perlu mengembalikan sisa TUP
  bool get needsReturnBalance {
    return sisaTup > 0 &&
           status == StatusPersetujuan.prosesSpj &&
           !isSudahDikembalikan;
  }

  /// Apakah SPJ sudah lengkap (semua terpakai di-SPJ-kan dan sisa dikembalikan)
  bool get isSpjComplete {
    final spjComplete = jumlahDipertanggungjawabkan >= jumlahTerpakai;
    final returnComplete = sisaTup == 0 || isSudahDikembalikan;
    return spjComplete && returnComplete;
  }

  TambahanUangPersediaan copyWith({
    String? id,
    String? nomorPengajuan,
    DateTime? tanggalPengajuan,
    double? jumlahPengajuan,
    double? jumlahDisetujui,
    AlasanTup? alasanPengajuan,
    String? uraianAlasan,
    String? rincianKebutuhan,
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
    StatusPersetujuan? status,
    String? catatanPpk,
    String? catatanBendahara,
    String? catatanKpa,
    String? alasanPenolakan,
    DateTime? tanggalVerifikasi,
    DateTime? tanggalPersetujuanKpa,
    DateTime? tanggalPencairan,
    DateTime? batasWaktuSpj,
    double? jumlahTerpakai,
    double? jumlahDipertanggungjawabkan,
    double? jumlahDikembalikan,
    bool? isSudahDikembalikan,
    String? nomorBuktiSetor,
    DateTime? tanggalSetor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TambahanUangPersediaan(
      id: id ?? this.id,
      nomorPengajuan: nomorPengajuan ?? this.nomorPengajuan,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      jumlahPengajuan: jumlahPengajuan ?? this.jumlahPengajuan,
      jumlahDisetujui: jumlahDisetujui ?? this.jumlahDisetujui,
      alasanPengajuan: alasanPengajuan ?? this.alasanPengajuan,
      uraianAlasan: uraianAlasan ?? this.uraianAlasan,
      rincianKebutuhan: rincianKebutuhan ?? this.rincianKebutuhan,
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
      status: status ?? this.status,
      catatanPpk: catatanPpk ?? this.catatanPpk,
      catatanBendahara: catatanBendahara ?? this.catatanBendahara,
      catatanKpa: catatanKpa ?? this.catatanKpa,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      tanggalPersetujuanKpa: tanggalPersetujuanKpa ?? this.tanggalPersetujuanKpa,
      tanggalPencairan: tanggalPencairan ?? this.tanggalPencairan,
      batasWaktuSpj: batasWaktuSpj ?? this.batasWaktuSpj,
      jumlahTerpakai: jumlahTerpakai ?? this.jumlahTerpakai,
      jumlahDipertanggungjawabkan: jumlahDipertanggungjawabkan ?? this.jumlahDipertanggungjawabkan,
      jumlahDikembalikan: jumlahDikembalikan ?? this.jumlahDikembalikan,
      isSudahDikembalikan: isSudahDikembalikan ?? this.isSudahDikembalikan,
      nomorBuktiSetor: nomorBuktiSetor ?? this.nomorBuktiSetor,
      tanggalSetor: tanggalSetor ?? this.tanggalSetor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nomorPengajuan,
        tanggalPengajuan,
        jumlahPengajuan,
        jumlahDisetujui,
        alasanPengajuan,
        uraianAlasan,
        rincianKebutuhan,
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
        status,
        catatanPpk,
        catatanBendahara,
        catatanKpa,
        alasanPenolakan,
        tanggalVerifikasi,
        tanggalPersetujuanKpa,
        tanggalPencairan,
        batasWaktuSpj,
        jumlahTerpakai,
        jumlahDipertanggungjawabkan,
        jumlahDikembalikan,
        isSudahDikembalikan,
        nomorBuktiSetor,
        tanggalSetor,
        createdAt,
        updatedAt,
      ];
}
