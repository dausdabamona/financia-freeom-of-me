import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';

/// States for CompassBloc
abstract class CompassState extends Equatable {
  const CompassState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class CompassInitial extends CompassState {
  const CompassInitial();
}

/// Loading state
class CompassLoading extends CompassState {
  const CompassLoading();
}

/// Loaded state with snapshot and compass data
class CompassLoaded extends CompassState {
  final FinancialSnapshot snapshot;
  final DailyCompassEntry compass;
  final bool isFirstTimeUser;

  const CompassLoaded({
    required this.snapshot,
    required this.compass,
    this.isFirstTimeUser = false,
  });

  @override
  List<Object?> get props => [snapshot, compass, isFirstTimeUser];

  /// Create a copy with updated compass (for marking completed)
  CompassLoaded copyWithCompass(DailyCompassEntry newCompass) {
    return CompassLoaded(
      snapshot: snapshot,
      compass: newCompass,
      isFirstTimeUser: isFirstTimeUser,
    );
  }
}

/// Empty state - no data yet (first time user)
class CompassEmpty extends CompassState {
  final String message;

  const CompassEmpty({
    this.message = 'Belum ada data. Mari mulai catat keuanganmu!',
  });

  @override
  List<Object?> get props => [message];
}

/// Error state
class CompassError extends CompassState {
  final String message;

  const CompassError({required this.message});

  @override
  List<Object?> get props => [message];
}
