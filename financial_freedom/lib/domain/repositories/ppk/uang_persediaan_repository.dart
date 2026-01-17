import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Repository contract untuk operasi Uang Persediaan (UP)
abstract class UangPersediaanRepository {
  /// Get all UP
  Future<Either<Failure, List<UangPersediaan>>> getAll();

  /// Get UP by id
  Future<Either<Failure, UangPersediaan>> getById(String id);

  /// Get UP by nomor pengajuan
  Future<Either<Failure, UangPersediaan>> getByNomorPengajuan(String nomor);

  /// Get UP by status
  Future<Either<Failure, List<UangPersediaan>>> getByStatus(StatusPersetujuan status);

  /// Get UP by tahun anggaran
  Future<Either<Failure, List<UangPersediaan>>> getByTahunAnggaran(String tahun);

  /// Get UP yang perlu di-SPJ-kan
  Future<Either<Failure, List<UangPersediaan>>> getPendingSpj();

  /// Get UP yang melewati batas waktu SPJ
  Future<Either<Failure, List<UangPersediaan>>> getOverdueSpj();

  /// Save UP baru
  Future<Either<Failure, void>> saveUp(UangPersediaan up);

  /// Update UP
  Future<Either<Failure, void>> updateUp(UangPersediaan up);

  /// Update status UP
  Future<Either<Failure, void>> updateStatus(String id, StatusPersetujuan status, {String? catatan});

  /// Update jumlah terpakai
  Future<Either<Failure, void>> updateJumlahTerpakai(String id, double jumlah);

  /// Update jumlah dipertanggungjawabkan
  Future<Either<Failure, void>> updateJumlahSpj(String id, double jumlah);

  /// Delete UP
  Future<Either<Failure, void>> deleteUp(String id);

  /// Watch all UP
  Stream<Either<Failure, List<UangPersediaan>>> watchAll();

  /// Watch UP by status
  Stream<Either<Failure, List<UangPersediaan>>> watchByStatus(StatusPersetujuan status);

  /// Get ringkasan UP per status
  Future<Either<Failure, Map<StatusPersetujuan, int>>> getSummaryByStatus();

  /// Get total UP yang sudah dicairkan
  Future<Either<Failure, double>> getTotalDicairkan();

  /// Generate nomor pengajuan baru
  Future<Either<Failure, String>> generateNomorPengajuan(String tahun, String kodeSatker);
}
