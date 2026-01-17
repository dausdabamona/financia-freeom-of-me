import 'package:equatable/equatable.dart';

/// Events untuk PPK Dashboard BLoC
abstract class PpkDashboardEvent extends Equatable {
  const PpkDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk load data dashboard
class LoadPpkDashboard extends PpkDashboardEvent {
  final String tahunAnggaran;

  const LoadPpkDashboard({required this.tahunAnggaran});

  @override
  List<Object?> get props => [tahunAnggaran];
}

/// Event untuk refresh data dashboard
class RefreshPpkDashboard extends PpkDashboardEvent {
  const RefreshPpkDashboard();
}

/// Event untuk filter berdasarkan tahun anggaran
class FilterByTahunAnggaran extends PpkDashboardEvent {
  final String tahunAnggaran;

  const FilterByTahunAnggaran({required this.tahunAnggaran});

  @override
  List<Object?> get props => [tahunAnggaran];
}
