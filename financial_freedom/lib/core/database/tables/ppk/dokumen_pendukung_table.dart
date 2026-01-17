import 'package:drift/drift.dart';

/// Table untuk menyimpan data dokumen pendukung UP/TUP
class DokumenPendukungTable extends Table {
  @override
  String get tableName => 'dokumen_pendukung';

  TextColumn get id => text()();
  TextColumn get referensiId => text().named('referensi_id')();
  TextColumn get referensiTipe => text().named('referensi_tipe')(); // UP atau TUP
  TextColumn get jenisDokumen => text().named('jenis_dokumen')();
  TextColumn get namaDokumen => text().named('nama_dokumen')();
  TextColumn get nomorDokumen => text().named('nomor_dokumen').nullable()();
  DateTimeColumn get tanggalDokumen => dateTime().named('tanggal_dokumen').nullable()();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileUrl => text().named('file_url').nullable()();
  IntColumn get fileSize => integer().named('file_size')();
  TextColumn get mimeType => text().named('mime_type')();
  TextColumn get keterangan => text().nullable()();
  BoolColumn get isVerified => boolean().named('is_verified').withDefault(const Constant(false))();
  TextColumn get verifiedBy => text().named('verified_by').nullable()();
  DateTimeColumn get verifiedAt => dateTime().named('verified_at').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
