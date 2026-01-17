import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/ppk/tambahan_uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Repository contract untuk operasi Tambahan Uang Persediaan (TUP)
abstract class TambahanUangPersediaanRepository {
  /// Get all TUP
  Future<Either<Failure, List<TambahanUangPersediaan>>> getAll();

  /// Get TUP by id
  Future<Either<Failure, TambahanUangPersediaan>> getById(String id);

  /// Get TUP by nomor pengajuan
  Future<Either<Failure, TambahanUangPersediaan>> getByNomorPengajuan(String nomor);

  /// Get TUP by status
  Future<Either<Failure, List<TambahanUangPersediaan>>> getByStatus(StatusPersetujuan status);

  /// Get TUP by tahun anggaran
  Future<Either<Failure, List<TambahanUangPersediaan>>> getByTahunAnggaran(String tahun);

  /// Get TUP by alasan pengajuan
  Future<Either<Failure, List<TambahanUangPersediaan>>> getByAlasan(AlasanTup alasan);

  /// Get TUP yang perlu di-SPJ-kan
  Future<Either<Failure, List<TambahanUangPersediaan>>> getPendingSpj();

  /// Get TUP yang melewati batas waktu SPJ
  Future<Either<Failure, List<TambahanUangPersediaan>>> getOverdueSpj();

  /// Get TUP yang perlu mengembalikan sisa
  Future<Either<Failure, List<TambahanUangPersediaan>>> getNeedReturnBalance();

  /// Save TUP baru
  Future<Either<Failure, void>> saveTup(TambahanUangPersediaan tup);

  /// Update TUP
  Future<Either<Failure, void>> updateTup(TambahanUangPersediaan tup);

  /// Update status TUP
  Future<Either<Failure, void>> updateStatus(String id, StatusPersetujuan status);

  /// Update jumlah terpakai
  Future<Either<Failure, void>> updateJumlahTerpakai(String id, double jumlah);

  /// Update jumlah dipertanggungjawabkan
  Future<Either<Failure, void>> updateJumlahSpj(String id, double jumlah);

  /// Update pengembalian sisa TUP
  Future<Either<Failure, void>> updatePengembalian(
    String id, {
    required double jumlahDikembalikan,
    required String nomorBuktiSetor,
    required DateTime tanggalSetor,
  });

  /// Delete TUP
  Future<Either<Failure, void>> deleteTup(String id);

  /// Watch all TUP
  Stream<Either<Failure, List<TambahanUangPersediaan>>> watchAll();

  /// Watch TUP by status
  Stream<Either<Failure, List<TambahanUangPersediaan>>> watchByStatus(StatusPersetujuan status);

  /// Get ringkasan TUP per status
  Future<Either<Failure, Map<StatusPersetujuan, int>>> getSummaryByStatus();

  /// Get total TUP yang sudah dicairkan
  Future<Either<Failure, double>> getTotalDicairkan();

  /// Get total sisa TUP yang perlu dikembalikan
  Future<Either<Failure, double>> getTotalSisaBelumDikembalikan();

  /// Generate nomor pengajuan baru
  Future<Either<Failure, String>> generateNomorPengajuan(String tahun, String kodeSatker);
}
