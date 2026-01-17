import 'package:drift/drift.dart';

/// Table untuk menyimpan riwayat persetujuan UP/TUP
class RiwayatPersetujuanTable extends Table {
  @override
  String get tableName => 'riwayat_persetujuan';

  TextColumn get id => text()();
  TextColumn get referensiId => text().named('referensi_id')();
  TextColumn get referensiTipe => text().named('referensi_tipe')(); // UP atau TUP
  TextColumn get tipeAksi => text().named('tipe_aksi')();
  TextColumn get statusSebelum => text().named('status_sebelum')();
  TextColumn get statusSesudah => text().named('status_sesudah')();
  TextColumn get pelakuId => text().named('pelaku_id')();
  TextColumn get pelakuNama => text().named('pelaku_nama')();
  TextColumn get pelakuPeran => text().named('pelaku_peran')();
  TextColumn get catatan => text().nullable()();
  TextColumn get alasan => text().nullable()();
  TextColumn get dataPerubahan => text().named('data_perubahan').nullable()(); // JSON string
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
