import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Events untuk Pengajuan UP BLoC
abstract class PengajuanUpEvent extends Equatable {
  const PengajuanUpEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk load semua UP
class LoadAllUp extends PengajuanUpEvent {
  final String? tahunAnggaran;

  const LoadAllUp({this.tahunAnggaran});

  @override
  List<Object?> get props => [tahunAnggaran];
}

/// Event untuk load UP by status
class LoadUpByStatus extends PengajuanUpEvent {
  final StatusPersetujuan status;

  const LoadUpByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Event untuk load detail UP
class LoadUpDetail extends PengajuanUpEvent {
  final String id;

  const LoadUpDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event untuk membuat UP baru
class CreateUp extends PengajuanUpEvent {
  final UangPersediaan up;

  const CreateUp({required this.up});

  @override
  List<Object?> get props => [up];
}

/// Event untuk update UP
class UpdateUp extends PengajuanUpEvent {
  final UangPersediaan up;

  const UpdateUp({required this.up});

  @override
  List<Object?> get props => [up];
}

/// Event untuk mengajukan UP
class SubmitUp extends PengajuanUpEvent {
  final String id;
  final String? catatan;

  const SubmitUp({required this.id, this.catatan});

  @override
  List<Object?> get props => [id, catatan];
}

/// Event untuk verifikasi UP
class VerifyUp extends PengajuanUpEvent {
  final String id;
  final String? catatan;

  const VerifyUp({required this.id, this.catatan});

  @override
  List<Object?> get props => [id, catatan];
}

/// Event untuk approve UP oleh KPA
class ApproveUp extends PengajuanUpEvent {
  final String id;
  final double jumlahDisetujui;
  final String? catatan;

  const ApproveUp({
    required this.id,
    required this.jumlahDisetujui,
    this.catatan,
  });

  @override
  List<Object?> get props => [id, jumlahDisetujui, catatan];
}

/// Event untuk reject UP
class RejectUp extends PengajuanUpEvent {
  final String id;
  final String alasanPenolakan;

  const RejectUp({required this.id, required this.alasanPenolakan});

  @override
  List<Object?> get props => [id, alasanPenolakan];
}

/// Event untuk mencairkan UP
class DisburseUp extends PengajuanUpEvent {
  final String id;
  final DateTime tanggalPencairan;
  final DateTime batasWaktuSpj;

  const DisburseUp({
    required this.id,
    required this.tanggalPencairan,
    required this.batasWaktuSpj,
  });

  @override
  List<Object?> get props => [id, tanggalPencairan, batasWaktuSpj];
}

/// Event untuk update penggunaan UP
class UpdateUpUsage extends PengajuanUpEvent {
  final String id;
  final double jumlahTerpakai;

  const UpdateUpUsage({required this.id, required this.jumlahTerpakai});

  @override
  List<Object?> get props => [id, jumlahTerpakai];
}

/// Event untuk update SPJ UP
class UpdateUpSpj extends PengajuanUpEvent {
  final String id;
  final double jumlahDipertanggungjawabkan;

  const UpdateUpSpj({required this.id, required this.jumlahDipertanggungjawabkan});

  @override
  List<Object?> get props => [id, jumlahDipertanggungjawabkan];
}

/// Event untuk menyelesaikan UP
class CompleteUp extends PengajuanUpEvent {
  final String id;

  const CompleteUp({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event untuk menghapus UP
class DeleteUp extends PengajuanUpEvent {
  final String id;

  const DeleteUp({required this.id});

  @override
  List<Object?> get props => [id];
}
