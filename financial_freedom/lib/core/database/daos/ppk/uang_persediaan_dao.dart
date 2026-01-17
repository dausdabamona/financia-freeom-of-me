import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/ppk/uang_persediaan_table.dart';

part 'uang_persediaan_dao.g.dart';

@DriftAccessor(tables: [UangPersediaanTable])
class UangPersediaanDao extends DatabaseAccessor<AppDatabase>
    with _$UangPersediaanDaoMixin {
  UangPersediaanDao(super.db);

  /// Get all UP
  Future<List<UangPersediaanTableData>> getAll() =>
      select(uangPersediaanTable).get();

  /// Get UP by id
  Future<UangPersediaanTableData?> getById(String id) {
    return (select(uangPersediaanTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get UP by nomor pengajuan
  Future<UangPersediaanTableData?> getByNomorPengajuan(String nomor) {
    return (select(uangPersediaanTable)
          ..where((t) => t.nomorPengajuan.equals(nomor)))
        .getSingleOrNull();
  }

  /// Get UP by status
  Future<List<UangPersediaanTableData>> getByStatus(String status) {
    return (select(uangPersediaanTable)..where((t) => t.status.equals(status)))
        .get();
  }

  /// Get UP by tahun anggaran
  Future<List<UangPersediaanTableData>> getByTahunAnggaran(String tahun) {
    return (select(uangPersediaanTable)
          ..where((t) => t.tahunAnggaran.equals(tahun)))
        .get();
  }

  /// Get UP yang perlu di-SPJ-kan (status dicairkan dan belum melewati batas waktu)
  Future<List<UangPersediaanTableData>> getPendingSpj() {
    return (select(uangPersediaanTable)
          ..where((t) => t.status.equals('dicairkan'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.batasWaktuSpj, mode: OrderingMode.asc)
          ]))
        .get();
  }

  /// Get UP yang melewati batas waktu SPJ
  Future<List<UangPersediaanTableData>> getOverdueSpj() {
    final now = DateTime.now();
    return (select(uangPersediaanTable)
          ..where((t) =>
              t.status.equals('dicairkan') & t.batasWaktuSpj.isSmallerThanValue(now)))
        .get();
  }

  /// Insert new UP
  Future<int> insertUp(UangPersediaanTableCompanion up) {
    return into(uangPersediaanTable).insert(up);
  }

  /// Update UP
  Future<bool> updateUp(UangPersediaanTableData up) {
    return update(uangPersediaanTable).replace(up);
  }

  /// Update status UP
  Future<int> updateStatus(String id, String newStatus, {String? catatan}) {
    return (update(uangPersediaanTable)..where((t) => t.id.equals(id))).write(
      UangPersediaanTableCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update jumlah terpakai
  Future<int> updateJumlahTerpakai(String id, double jumlah) {
    return (update(uangPersediaanTable)..where((t) => t.id.equals(id))).write(
      UangPersediaanTableCompanion(
        jumlahTerpakai: Value(jumlah),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update jumlah dipertanggungjawabkan
  Future<int> updateJumlahSpj(String id, double jumlah) {
    return (update(uangPersediaanTable)..where((t) => t.id.equals(id))).write(
      UangPersediaanTableCompanion(
        jumlahDipertanggungjawabkan: Value(jumlah),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete UP
  Future<int> deleteUp(String id) {
    return (delete(uangPersediaanTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watch all UP
  Stream<List<UangPersediaanTableData>> watchAll() =>
      select(uangPersediaanTable).watch();

  /// Watch UP by status
  Stream<List<UangPersediaanTableData>> watchByStatus(String status) {
    return (select(uangPersediaanTable)..where((t) => t.status.equals(status)))
        .watch();
  }

  /// Get ringkasan UP per status
  Future<Map<String, int>> getSummaryByStatus() async {
    final all = await getAll();
    final summary = <String, int>{};
    for (final up in all) {
      summary[up.status] = (summary[up.status] ?? 0) + 1;
    }
    return summary;
  }

  /// Get total UP yang sudah dicairkan
  Future<double> getTotalDicairkan() async {
    final dicairkan = await getByStatus('dicairkan');
    final selesai = await getByStatus('selesai');
    return [...dicairkan, ...selesai]
        .fold<double>(0.0, (sum, up) => sum + up.jumlahDisetujui);
  }
}
