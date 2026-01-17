import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/ppk/tambahan_uang_persediaan_table.dart';

part 'tambahan_uang_persediaan_dao.g.dart';

@DriftAccessor(tables: [TambahanUangPersediaanTable])
class TambahanUangPersediaanDao extends DatabaseAccessor<AppDatabase>
    with _$TambahanUangPersediaanDaoMixin {
  TambahanUangPersediaanDao(super.db);

  /// Get all TUP
  Future<List<TambahanUangPersediaanTableData>> getAll() =>
      select(tambahanUangPersediaanTable).get();

  /// Get TUP by id
  Future<TambahanUangPersediaanTableData?> getById(String id) {
    return (select(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get TUP by nomor pengajuan
  Future<TambahanUangPersediaanTableData?> getByNomorPengajuan(String nomor) {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.nomorPengajuan.equals(nomor)))
        .getSingleOrNull();
  }

  /// Get TUP by status
  Future<List<TambahanUangPersediaanTableData>> getByStatus(String status) {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.status.equals(status)))
        .get();
  }

  /// Get TUP by tahun anggaran
  Future<List<TambahanUangPersediaanTableData>> getByTahunAnggaran(String tahun) {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.tahunAnggaran.equals(tahun)))
        .get();
  }

  /// Get TUP by alasan pengajuan
  Future<List<TambahanUangPersediaanTableData>> getByAlasan(String alasan) {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.alasanPengajuan.equals(alasan)))
        .get();
  }

  /// Get TUP yang perlu di-SPJ-kan
  Future<List<TambahanUangPersediaanTableData>> getPendingSpj() {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.status.equals('dicairkan'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.batasWaktuSpj, mode: OrderingMode.asc)
          ]))
        .get();
  }

  /// Get TUP yang melewati batas waktu SPJ
  Future<List<TambahanUangPersediaanTableData>> getOverdueSpj() {
    final now = DateTime.now();
    return (select(tambahanUangPersediaanTable)
          ..where((t) =>
              t.status.equals('dicairkan') &
              t.batasWaktuSpj.isSmallerThanValue(now)))
        .get();
  }

  /// Get TUP yang perlu dikembalikan sisanya
  Future<List<TambahanUangPersediaanTableData>> getNeedReturnBalance() {
    return (select(tambahanUangPersediaanTable)
          ..where((t) =>
              t.status.equals('proses_spj') &
              t.isSudahDikembalikan.equals(false)))
        .get();
  }

  /// Insert new TUP
  Future<int> insertTup(TambahanUangPersediaanTableCompanion tup) {
    return into(tambahanUangPersediaanTable).insert(tup);
  }

  /// Update TUP
  Future<bool> updateTup(TambahanUangPersediaanTableData tup) {
    return update(tambahanUangPersediaanTable).replace(tup);
  }

  /// Update status TUP
  Future<int> updateStatus(String id, String newStatus) {
    return (update(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .write(
      TambahanUangPersediaanTableCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update jumlah terpakai
  Future<int> updateJumlahTerpakai(String id, double jumlah) {
    return (update(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .write(
      TambahanUangPersediaanTableCompanion(
        jumlahTerpakai: Value(jumlah),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update jumlah dipertanggungjawabkan
  Future<int> updateJumlahSpj(String id, double jumlah) {
    return (update(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .write(
      TambahanUangPersediaanTableCompanion(
        jumlahDipertanggungjawabkan: Value(jumlah),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update pengembalian sisa TUP
  Future<int> updatePengembalian(
    String id, {
    required double jumlahDikembalikan,
    required String nomorBuktiSetor,
    required DateTime tanggalSetor,
  }) {
    return (update(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .write(
      TambahanUangPersediaanTableCompanion(
        jumlahDikembalikan: Value(jumlahDikembalikan),
        isSudahDikembalikan: const Value(true),
        nomorBuktiSetor: Value(nomorBuktiSetor),
        tanggalSetor: Value(tanggalSetor),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete TUP
  Future<int> deleteTup(String id) {
    return (delete(tambahanUangPersediaanTable)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Watch all TUP
  Stream<List<TambahanUangPersediaanTableData>> watchAll() =>
      select(tambahanUangPersediaanTable).watch();

  /// Watch TUP by status
  Stream<List<TambahanUangPersediaanTableData>> watchByStatus(String status) {
    return (select(tambahanUangPersediaanTable)
          ..where((t) => t.status.equals(status)))
        .watch();
  }

  /// Get ringkasan TUP per status
  Future<Map<String, int>> getSummaryByStatus() async {
    final all = await getAll();
    final summary = <String, int>{};
    for (final tup in all) {
      summary[tup.status] = (summary[tup.status] ?? 0) + 1;
    }
    return summary;
  }

  /// Get total TUP yang sudah dicairkan
  Future<double> getTotalDicairkan() async {
    final dicairkan = await getByStatus('dicairkan');
    final selesai = await getByStatus('selesai');
    return [...dicairkan, ...selesai]
        .fold<double>(0.0, (sum, tup) => sum + tup.jumlahDisetujui);
  }

  /// Get total sisa TUP yang perlu dikembalikan
  Future<double> getTotalSisaBelumDikembalikan() async {
    final pending = await getNeedReturnBalance();
    return pending.fold<double>(
        0.0, (sum, tup) => sum + (tup.jumlahDisetujui - tup.jumlahTerpakai));
  }
}
