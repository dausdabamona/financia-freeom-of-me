import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/ppk/riwayat_persetujuan_table.dart';

part 'riwayat_persetujuan_dao.g.dart';

@DriftAccessor(tables: [RiwayatPersetujuanTable])
class RiwayatPersetujuanDao extends DatabaseAccessor<AppDatabase>
    with _$RiwayatPersetujuanDaoMixin {
  RiwayatPersetujuanDao(super.db);

  /// Get all riwayat
  Future<List<RiwayatPersetujuanTableData>> getAll() =>
      select(riwayatPersetujuanTable).get();

  /// Get riwayat by id
  Future<RiwayatPersetujuanTableData?> getById(String id) {
    return (select(riwayatPersetujuanTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get riwayat by referensi (UP atau TUP)
  Future<List<RiwayatPersetujuanTableData>> getByReferensi(
      String referensiId, String referensiTipe) {
    return (select(riwayatPersetujuanTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get riwayat by pelaku
  Future<List<RiwayatPersetujuanTableData>> getByPelaku(String pelakuId) {
    return (select(riwayatPersetujuanTable)
          ..where((t) => t.pelakuId.equals(pelakuId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get riwayat by tipe aksi
  Future<List<RiwayatPersetujuanTableData>> getByTipeAksi(String tipeAksi) {
    return (select(riwayatPersetujuanTable)
          ..where((t) => t.tipeAksi.equals(tipeAksi))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get riwayat dalam rentang waktu
  Future<List<RiwayatPersetujuanTableData>> getByDateRange(
      DateTime startDate, DateTime endDate) {
    return (select(riwayatPersetujuanTable)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startDate) &
              t.createdAt.isSmallerOrEqualValue(endDate))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get riwayat terbaru
  Future<List<RiwayatPersetujuanTableData>> getRecent({int limit = 20}) {
    return (select(riwayatPersetujuanTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  /// Get riwayat terakhir untuk referensi
  Future<RiwayatPersetujuanTableData?> getLastByReferensi(
      String referensiId, String referensiTipe) {
    return (select(riwayatPersetujuanTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Insert new riwayat
  Future<int> insertRiwayat(RiwayatPersetujuanTableCompanion riwayat) {
    return into(riwayatPersetujuanTable).insert(riwayat);
  }

  /// Delete riwayat
  Future<int> deleteRiwayat(String id) {
    return (delete(riwayatPersetujuanTable)..where((t) => t.id.equals(id))).go();
  }

  /// Delete semua riwayat untuk referensi
  Future<int> deleteByReferensi(String referensiId, String referensiTipe) {
    return (delete(riwayatPersetujuanTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe)))
        .go();
  }

  /// Watch riwayat by referensi
  Stream<List<RiwayatPersetujuanTableData>> watchByReferensi(
      String referensiId, String referensiTipe) {
    return (select(riwayatPersetujuanTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Watch riwayat terbaru
  Stream<List<RiwayatPersetujuanTableData>> watchRecent({int limit = 20}) {
    return (select(riwayatPersetujuanTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }

  /// Get statistik aksi per pelaku
  Future<Map<String, int>> getStatsByPelaku(String pelakuId) async {
    final riwayat = await getByPelaku(pelakuId);
    final stats = <String, int>{};
    for (final r in riwayat) {
      stats[r.tipeAksi] = (stats[r.tipeAksi] ?? 0) + 1;
    }
    return stats;
  }

  /// Get jumlah aksi per hari dalam sebulan
  Future<Map<int, int>> getActivityByDayInMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    final riwayat = await getByDateRange(startDate, endDate);

    final activity = <int, int>{};
    for (final r in riwayat) {
      final day = r.createdAt.day;
      activity[day] = (activity[day] ?? 0) + 1;
    }
    return activity;
  }
}
