import 'package:drift/drift.dart';

/// Table untuk menyimpan data Tambahan Uang Persediaan (TUP)
class TambahanUangPersediaanTable extends Table {
  @override
  String get tableName => 'tambahan_uang_persediaan';

  TextColumn get id => text()();
  TextColumn get nomorPengajuan => text().named('nomor_pengajuan')();
  DateTimeColumn get tanggalPengajuan => dateTime().named('tanggal_pengajuan')();
  RealColumn get jumlahPengajuan => real().named('jumlah_pengajuan')();
  RealColumn get jumlahDisetujui => real().named('jumlah_disetujui').withDefault(const Constant(0))();
  TextColumn get alasanPengajuan => text().named('alasan_pengajuan')(); // enum AlasanTup
  TextColumn get uraianAlasan => text().named('uraian_alasan')();
  TextColumn get rincianKebutuhan => text().named('rincian_kebutuhan')();
  TextColumn get tahunAnggaran => text().named('tahun_anggaran')();
  TextColumn get kodeSatker => text().named('kode_satker')();
  TextColumn get namaSatker => text().named('nama_satker')();
  TextColumn get kodeProgram => text().named('kode_program')();
  TextColumn get namaProgram => text().named('nama_program')();
  TextColumn get kodeKegiatan => text().named('kode_kegiatan')();
  TextColumn get namaKegiatan => text().named('nama_kegiatan')();
  TextColumn get kodeOutput => text().named('kode_output')();
  TextColumn get namaOutput => text().named('nama_output')();
  TextColumn get kodeAkun => text().named('kode_akun')();
  TextColumn get namaAkun => text().named('nama_akun')();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get catatanPpk => text().named('catatan_ppk').nullable()();
  TextColumn get catatanBendahara => text().named('catatan_bendahara').nullable()();
  TextColumn get catatanKpa => text().named('catatan_kpa').nullable()();
  TextColumn get alasanPenolakan => text().named('alasan_penolakan').nullable()();
  DateTimeColumn get tanggalVerifikasi => dateTime().named('tanggal_verifikasi').nullable()();
  DateTimeColumn get tanggalPersetujuanKpa => dateTime().named('tanggal_persetujuan_kpa').nullable()();
  DateTimeColumn get tanggalPencairan => dateTime().named('tanggal_pencairan').nullable()();
  DateTimeColumn get batasWaktuSpj => dateTime().named('batas_waktu_spj')();
  RealColumn get jumlahTerpakai => real().named('jumlah_terpakai').withDefault(const Constant(0))();
  RealColumn get jumlahDipertanggungjawabkan => real().named('jumlah_dipertanggungjawabkan').withDefault(const Constant(0))();
  RealColumn get jumlahDikembalikan => real().named('jumlah_dikembalikan').withDefault(const Constant(0))();
  BoolColumn get isSudahDikembalikan => boolean().named('is_sudah_dikembalikan').withDefault(const Constant(false))();
  TextColumn get nomorBuktiSetor => text().named('nomor_bukti_setor').nullable()();
  DateTimeColumn get tanggalSetor => dateTime().named('tanggal_setor').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
