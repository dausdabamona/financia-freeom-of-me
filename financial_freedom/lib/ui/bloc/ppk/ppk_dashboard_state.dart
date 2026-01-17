import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/tambahan_uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// State untuk PPK Dashboard BLoC
abstract class PpkDashboardState extends Equatable {
  const PpkDashboardState();

  @override
  List<Object?> get props => [];
}

/// State awal
class PpkDashboardInitial extends PpkDashboardState {
  const PpkDashboardInitial();
}

/// State loading
class PpkDashboardLoading extends PpkDashboardState {
  const PpkDashboardLoading();
}

/// State berhasil load data
class PpkDashboardLoaded extends PpkDashboardState {
  final String tahunAnggaran;
  final List<UangPersediaan> listUp;
  final List<TambahanUangPersediaan> listTup;
  final Map<StatusPersetujuan, int> summaryUpByStatus;
  final Map<StatusPersetujuan, int> summaryTupByStatus;
  final double totalUpDicairkan;
  final double totalTupDicairkan;
  final List<UangPersediaan> upPendingSpj;
  final List<TambahanUangPersediaan> tupPendingSpj;
  final List<UangPersediaan> upOverdueSpj;
  final List<TambahanUangPersediaan> tupOverdueSpj;
  final List<TambahanUangPersediaan> tupNeedReturn;
  final double totalSisaTupBelumDikembalikan;

  const PpkDashboardLoaded({
    required this.tahunAnggaran,
    required this.listUp,
    required this.listTup,
    required this.summaryUpByStatus,
    required this.summaryTupByStatus,
    required this.totalUpDicairkan,
    required this.totalTupDicairkan,
    required this.upPendingSpj,
    required this.tupPendingSpj,
    required this.upOverdueSpj,
    required this.tupOverdueSpj,
    required this.tupNeedReturn,
    required this.totalSisaTupBelumDikembalikan,
  });

  /// Total jumlah UP aktif
  int get totalUpAktif => listUp.length;

  /// Total jumlah TUP aktif
  int get totalTupAktif => listTup.length;

  /// Total pengajuan yang perlu perhatian
  int get totalPerluPerhatian =>
      upPendingSpj.length +
      tupPendingSpj.length +
      upOverdueSpj.length +
      tupOverdueSpj.length +
      tupNeedReturn.length;

  /// Total dana yang sudah dicairkan (UP + TUP)
  double get totalDicairkan => totalUpDicairkan + totalTupDicairkan;

  /// Apakah ada SPJ yang overdue
  bool get hasOverdueSpj => upOverdueSpj.isNotEmpty || tupOverdueSpj.isNotEmpty;

  @override
  List<Object?> get props => [
        tahunAnggaran,
        listUp,
        listTup,
        summaryUpByStatus,
        summaryTupByStatus,
        totalUpDicairkan,
        totalTupDicairkan,
        upPendingSpj,
        tupPendingSpj,
        upOverdueSpj,
        tupOverdueSpj,
        tupNeedReturn,
        totalSisaTupBelumDikembalikan,
      ];
}

/// State error
class PpkDashboardError extends PpkDashboardState {
  final String message;

  const PpkDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
