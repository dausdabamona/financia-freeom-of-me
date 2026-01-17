import 'package:equatable/equatable.dart';

/// Jenis dokumen pendukung UP/TUP
enum JenisDokumen {
  /// Surat Permohonan UP/TUP
  suratPermohonan,

  /// Rincian Kebutuhan Dana
  rincianKebutuhan,

  /// Surat Pernyataan KPA
  suratPernyataanKpa,

  /// Kuitansi/Bukti Pembayaran
  kuitansi,

  /// Faktur Pajak
  fakturPajak,

  /// Bukti Setor Pajak
  buktiSetorPajak,

  /// Berita Acara
  beritaAcara,

  /// Surat Tugas
  suratTugas,

  /// SPTJM (Surat Pernyataan Tanggung Jawab Mutlak)
  sptjm,

  /// Daftar Nominatif
  daftarNominatif,

  /// Bukti Transfer
  buktiTransfer,

  /// Bukti Setor Sisa TUP
  buktiSetorSisaTup,

  /// Dokumentasi Kegiatan
  dokumentasiKegiatan,

  /// Dokumen Lainnya
  lainnya,
}

extension JenisDokumenExtension on JenisDokumen {
  String get label {
    switch (this) {
      case JenisDokumen.suratPermohonan:
        return 'Surat Permohonan UP/TUP';
      case JenisDokumen.rincianKebutuhan:
        return 'Rincian Kebutuhan Dana';
      case JenisDokumen.suratPernyataanKpa:
        return 'Surat Pernyataan KPA';
      case JenisDokumen.kuitansi:
        return 'Kuitansi/Bukti Pembayaran';
      case JenisDokumen.fakturPajak:
        return 'Faktur Pajak';
      case JenisDokumen.buktiSetorPajak:
        return 'Bukti Setor Pajak';
      case JenisDokumen.beritaAcara:
        return 'Berita Acara';
      case JenisDokumen.suratTugas:
        return 'Surat Tugas';
      case JenisDokumen.sptjm:
        return 'SPTJM';
      case JenisDokumen.daftarNominatif:
        return 'Daftar Nominatif';
      case JenisDokumen.buktiTransfer:
        return 'Bukti Transfer';
      case JenisDokumen.buktiSetorSisaTup:
        return 'Bukti Setor Sisa TUP';
      case JenisDokumen.dokumentasiKegiatan:
        return 'Dokumentasi Kegiatan';
      case JenisDokumen.lainnya:
        return 'Dokumen Lainnya';
    }
  }

  bool get isWajibUp {
    return this == JenisDokumen.suratPermohonan ||
           this == JenisDokumen.rincianKebutuhan;
  }

  bool get isWajibTup {
    return this == JenisDokumen.suratPermohonan ||
           this == JenisDokumen.rincianKebutuhan ||
           this == JenisDokumen.suratPernyataanKpa;
  }

  bool get isWajibSpj {
    return this == JenisDokumen.kuitansi || this == JenisDokumen.sptjm;
  }
}

/// Entity Dokumen Pendukung
class DokumenPendukung extends Equatable {
  final String id;
  final String referensiId; // ID UP atau TUP
  final String referensiTipe; // 'UP' atau 'TUP'
  final JenisDokumen jenisDokumen;
  final String namaDokumen;
  final String? nomorDokumen;
  final DateTime? tanggalDokumen;
  final String filePath;
  final String? fileUrl; // Jika disimpan di cloud
  final int fileSize; // Dalam bytes
  final String mimeType;
  final String? keterangan;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DokumenPendukung({
    required this.id,
    required this.referensiId,
    required this.referensiTipe,
    required this.jenisDokumen,
    required this.namaDokumen,
    this.nomorDokumen,
    this.tanggalDokumen,
    required this.filePath,
    this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    this.keterangan,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Format ukuran file untuk ditampilkan
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  DokumenPendukung copyWith({
    String? id,
    String? referensiId,
    String? referensiTipe,
    JenisDokumen? jenisDokumen,
    String? namaDokumen,
    String? nomorDokumen,
    DateTime? tanggalDokumen,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    String? keterangan,
    bool? isVerified,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DokumenPendukung(
      id: id ?? this.id,
      referensiId: referensiId ?? this.referensiId,
      referensiTipe: referensiTipe ?? this.referensiTipe,
      jenisDokumen: jenisDokumen ?? this.jenisDokumen,
      namaDokumen: namaDokumen ?? this.namaDokumen,
      nomorDokumen: nomorDokumen ?? this.nomorDokumen,
      tanggalDokumen: tanggalDokumen ?? this.tanggalDokumen,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      keterangan: keterangan ?? this.keterangan,
      isVerified: isVerified ?? this.isVerified,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        referensiId,
        referensiTipe,
        jenisDokumen,
        namaDokumen,
        nomorDokumen,
        tanggalDokumen,
        filePath,
        fileUrl,
        fileSize,
        mimeType,
        keterangan,
        isVerified,
        verifiedBy,
        verifiedAt,
        createdAt,
        updatedAt,
      ];
}
