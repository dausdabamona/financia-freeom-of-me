import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/ppk/dokumen_pendukung_table.dart';

part 'dokumen_pendukung_dao.g.dart';

@DriftAccessor(tables: [DokumenPendukungTable])
class DokumenPendukungDao extends DatabaseAccessor<AppDatabase>
    with _$DokumenPendukungDaoMixin {
  DokumenPendukungDao(super.db);

  /// Get all dokumen
  Future<List<DokumenPendukungTableData>> getAll() =>
      select(dokumenPendukungTable).get();

  /// Get dokumen by id
  Future<DokumenPendukungTableData?> getById(String id) {
    return (select(dokumenPendukungTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get dokumen by referensi (UP atau TUP)
  Future<List<DokumenPendukungTableData>> getByReferensi(
      String referensiId, String referensiTipe) {
    return (select(dokumenPendukungTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get dokumen by jenis
  Future<List<DokumenPendukungTableData>> getByJenis(String jenisDokumen) {
    return (select(dokumenPendukungTable)
          ..where((t) => t.jenisDokumen.equals(jenisDokumen)))
        .get();
  }

  /// Get dokumen yang belum diverifikasi
  Future<List<DokumenPendukungTableData>> getUnverified() {
    return (select(dokumenPendukungTable)
          ..where((t) => t.isVerified.equals(false)))
        .get();
  }

  /// Get dokumen yang belum diverifikasi untuk referensi tertentu
  Future<List<DokumenPendukungTableData>> getUnverifiedByReferensi(
      String referensiId, String referensiTipe) {
    return (select(dokumenPendukungTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe) &
              t.isVerified.equals(false)))
        .get();
  }

  /// Insert new dokumen
  Future<int> insertDokumen(DokumenPendukungTableCompanion dokumen) {
    return into(dokumenPendukungTable).insert(dokumen);
  }

  /// Update dokumen
  Future<bool> updateDokumen(DokumenPendukungTableData dokumen) {
    return update(dokumenPendukungTable).replace(dokumen);
  }

  /// Verifikasi dokumen
  Future<int> verifyDokumen(String id, String verifiedBy) {
    return (update(dokumenPendukungTable)..where((t) => t.id.equals(id))).write(
      DokumenPendukungTableCompanion(
        isVerified: const Value(true),
        verifiedBy: Value(verifiedBy),
        verifiedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Batalkan verifikasi dokumen
  Future<int> unverifyDokumen(String id) {
    return (update(dokumenPendukungTable)..where((t) => t.id.equals(id))).write(
      const DokumenPendukungTableCompanion(
        isVerified: Value(false),
        verifiedBy: Value(null),
        verifiedAt: Value(null),
      ),
    );
  }

  /// Delete dokumen
  Future<int> deleteDokumen(String id) {
    return (delete(dokumenPendukungTable)..where((t) => t.id.equals(id))).go();
  }

  /// Delete semua dokumen untuk referensi tertentu
  Future<int> deleteByReferensi(String referensiId, String referensiTipe) {
    return (delete(dokumenPendukungTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe)))
        .go();
  }

  /// Watch dokumen by referensi
  Stream<List<DokumenPendukungTableData>> watchByReferensi(
      String referensiId, String referensiTipe) {
    return (select(dokumenPendukungTable)
          ..where((t) =>
              t.referensiId.equals(referensiId) &
              t.referensiTipe.equals(referensiTipe))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Cek kelengkapan dokumen wajib untuk UP
  Future<Map<String, bool>> checkKelengkapanDokumenUp(String upId) async {
    final dokumen = await getByReferensi(upId, 'UP');
    final jenisAda = dokumen.map((d) => d.jenisDokumen).toSet();

    return {
      'suratPermohonan': jenisAda.contains('suratPermohonan'),
      'rincianKebutuhan': jenisAda.contains('rincianKebutuhan'),
    };
  }

  /// Cek kelengkapan dokumen wajib untuk TUP
  Future<Map<String, bool>> checkKelengkapanDokumenTup(String tupId) async {
    final dokumen = await getByReferensi(tupId, 'TUP');
    final jenisAda = dokumen.map((d) => d.jenisDokumen).toSet();

    return {
      'suratPermohonan': jenisAda.contains('suratPermohonan'),
      'rincianKebutuhan': jenisAda.contains('rincianKebutuhan'),
      'suratPernyataanKpa': jenisAda.contains('suratPernyataanKpa'),
    };
  }

  /// Get total ukuran file untuk referensi
  Future<int> getTotalFileSize(String referensiId, String referensiTipe) async {
    final dokumen = await getByReferensi(referensiId, referensiTipe);
    return dokumen.fold<int>(0, (sum, d) => sum + d.fileSize);
  }
}
