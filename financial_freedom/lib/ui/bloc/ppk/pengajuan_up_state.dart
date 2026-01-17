import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';

/// State untuk Pengajuan UP BLoC
abstract class PengajuanUpState extends Equatable {
  const PengajuanUpState();

  @override
  List<Object?> get props => [];
}

/// State awal
class PengajuanUpInitial extends PengajuanUpState {
  const PengajuanUpInitial();
}

/// State loading
class PengajuanUpLoading extends PengajuanUpState {
  const PengajuanUpLoading();
}

/// State berhasil load list UP
class PengajuanUpListLoaded extends PengajuanUpState {
  final List<UangPersediaan> listUp;
  final String? filterTahun;

  const PengajuanUpListLoaded({
    required this.listUp,
    this.filterTahun,
  });

  @override
  List<Object?> get props => [listUp, filterTahun];
}

/// State berhasil load detail UP
class PengajuanUpDetailLoaded extends PengajuanUpState {
  final UangPersediaan up;

  const PengajuanUpDetailLoaded({required this.up});

  @override
  List<Object?> get props => [up];
}

/// State berhasil create UP
class PengajuanUpCreated extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpCreated({
    required this.up,
    this.message = 'UP berhasil dibuat',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil update UP
class PengajuanUpUpdated extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpUpdated({
    required this.up,
    this.message = 'UP berhasil diperbarui',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil submit UP
class PengajuanUpSubmitted extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpSubmitted({
    required this.up,
    this.message = 'UP berhasil diajukan',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil verify UP
class PengajuanUpVerified extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpVerified({
    required this.up,
    this.message = 'UP berhasil diverifikasi',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil approve UP
class PengajuanUpApproved extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpApproved({
    required this.up,
    this.message = 'UP berhasil disetujui',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil reject UP
class PengajuanUpRejected extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpRejected({
    required this.up,
    this.message = 'UP ditolak',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil disburse UP
class PengajuanUpDisbursed extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpDisbursed({
    required this.up,
    this.message = 'UP berhasil dicairkan',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil complete UP
class PengajuanUpCompleted extends PengajuanUpState {
  final UangPersediaan up;
  final String message;

  const PengajuanUpCompleted({
    required this.up,
    this.message = 'UP berhasil diselesaikan',
  });

  @override
  List<Object?> get props => [up, message];
}

/// State berhasil delete UP
class PengajuanUpDeleted extends PengajuanUpState {
  final String id;
  final String message;

  const PengajuanUpDeleted({
    required this.id,
    this.message = 'UP berhasil dihapus',
  });

  @override
  List<Object?> get props => [id, message];
}

/// State error
class PengajuanUpError extends PengajuanUpState {
  final String message;

  const PengajuanUpError({required this.message});

  @override
  List<Object?> get props => [message];
}
