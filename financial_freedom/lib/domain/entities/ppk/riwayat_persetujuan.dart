import 'package:equatable/equatable.dart';
import 'status_persetujuan.dart';

/// Tipe aksi dalam riwayat persetujuan
enum TipeAksi {
  /// Membuat pengajuan baru
  buatPengajuan,

  /// Mengajukan ke tahap berikutnya
  ajukan,

  /// Melakukan verifikasi
  verifikasi,

  /// Memberikan persetujuan
  setujui,

  /// Menolak pengajuan
  tolak,

  /// Mencairkan dana
  cairkan,

  /// Memproses SPJ
  prosesSpj,

  /// Menyelesaikan pengajuan
  selesaikan,

  /// Mengedit pengajuan
  edit,

  /// Menambah dokumen
  tambahDokumen,

  /// Memberikan catatan
  beriCatatan,

  /// Mengembalikan sisa dana
  kembalikanSisa,
}

extension TipeAksiExtension on TipeAksi {
  String get label {
    switch (this) {
      case TipeAksi.buatPengajuan:
        return 'Membuat Pengajuan';
      case TipeAksi.ajukan:
        return 'Mengajukan';
      case TipeAksi.verifikasi:
        return 'Memverifikasi';
      case TipeAksi.setujui:
        return 'Menyetujui';
      case TipeAksi.tolak:
        return 'Menolak';
      case TipeAksi.cairkan:
        return 'Mencairkan';
      case TipeAksi.prosesSpj:
        return 'Memproses SPJ';
      case TipeAksi.selesaikan:
        return 'Menyelesaikan';
      case TipeAksi.edit:
        return 'Mengedit';
      case TipeAksi.tambahDokumen:
        return 'Menambah Dokumen';
      case TipeAksi.beriCatatan:
        return 'Memberikan Catatan';
      case TipeAksi.kembalikanSisa:
        return 'Mengembalikan Sisa Dana';
    }
  }
}

/// Peran pengguna dalam sistem
enum PeranPengguna {
  /// Pejabat Pembuat Komitmen
  ppk,

  /// Bendahara Pengeluaran
  bendahara,

  /// Kuasa Pengguna Anggaran
  kpa,

  /// Pejabat Penanda Tangan SPM
  ppSpm,

  /// Admin/Staff
  admin,
}

extension PeranPenggunaExtension on PeranPengguna {
  String get label {
    switch (this) {
      case PeranPengguna.ppk:
        return 'PPK';
      case PeranPengguna.bendahara:
        return 'Bendahara Pengeluaran';
      case PeranPengguna.kpa:
        return 'KPA';
      case PeranPengguna.ppSpm:
        return 'PP-SPM';
      case PeranPengguna.admin:
        return 'Admin';
    }
  }

  String get namaLengkap {
    switch (this) {
      case PeranPengguna.ppk:
        return 'Pejabat Pembuat Komitmen';
      case PeranPengguna.bendahara:
        return 'Bendahara Pengeluaran';
      case PeranPengguna.kpa:
        return 'Kuasa Pengguna Anggaran';
      case PeranPengguna.ppSpm:
        return 'Pejabat Penanda Tangan SPM';
      case PeranPengguna.admin:
        return 'Administrator';
    }
  }
}

/// Entity Riwayat Persetujuan
///
/// Mencatat setiap aksi yang dilakukan pada pengajuan UP/TUP
class RiwayatPersetujuan extends Equatable {
  final String id;
  final String referensiId; // ID UP atau TUP
  final String referensiTipe; // 'UP' atau 'TUP'
  final TipeAksi tipeAksi;
  final StatusPersetujuan statusSebelum;
  final StatusPersetujuan statusSesudah;
  final String pelakuId;
  final String pelakuNama;
  final PeranPengguna pelakuPeran;
  final String? catatan;
  final String? alasan;
  final Map<String, dynamic>? dataPerubahan; // Perubahan data jika ada
  final DateTime createdAt;

  const RiwayatPersetujuan({
    required this.id,
    required this.referensiId,
    required this.referensiTipe,
    required this.tipeAksi,
    required this.statusSebelum,
    required this.statusSesudah,
    required this.pelakuId,
    required this.pelakuNama,
    required this.pelakuPeran,
    this.catatan,
    this.alasan,
    this.dataPerubahan,
    required this.createdAt,
  });

  /// Deskripsi aksi yang dilakukan
  String get deskripsiAksi {
    final aksi = tipeAksi.label.toLowerCase();
    return '${pelakuNama} (${pelakuPeran.label}) $aksi pengajuan';
  }

  RiwayatPersetujuan copyWith({
    String? id,
    String? referensiId,
    String? referensiTipe,
    TipeAksi? tipeAksi,
    StatusPersetujuan? statusSebelum,
    StatusPersetujuan? statusSesudah,
    String? pelakuId,
    String? pelakuNama,
    PeranPengguna? pelakuPeran,
    String? catatan,
    String? alasan,
    Map<String, dynamic>? dataPerubahan,
    DateTime? createdAt,
  }) {
    return RiwayatPersetujuan(
      id: id ?? this.id,
      referensiId: referensiId ?? this.referensiId,
      referensiTipe: referensiTipe ?? this.referensiTipe,
      tipeAksi: tipeAksi ?? this.tipeAksi,
      statusSebelum: statusSebelum ?? this.statusSebelum,
      statusSesudah: statusSesudah ?? this.statusSesudah,
      pelakuId: pelakuId ?? this.pelakuId,
      pelakuNama: pelakuNama ?? this.pelakuNama,
      pelakuPeran: pelakuPeran ?? this.pelakuPeran,
      catatan: catatan ?? this.catatan,
      alasan: alasan ?? this.alasan,
      dataPerubahan: dataPerubahan ?? this.dataPerubahan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        referensiId,
        referensiTipe,
        tipeAksi,
        statusSebelum,
        statusSesudah,
        pelakuId,
        pelakuNama,
        pelakuPeran,
        catatan,
        alasan,
        dataPerubahan,
        createdAt,
      ];
}
