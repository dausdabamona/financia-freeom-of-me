import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/repositories/daily_compass_repository.dart';
import 'package:financial_freedom/domain/usecases/generate_daily_snapshot.dart';
import 'package:financial_freedom/ui/bloc/compass/compass_event.dart';
import 'package:financial_freedom/ui/bloc/compass/compass_state.dart';

/// BLoC for managing compass screen state
///
/// Handles:
/// - Loading today's snapshot and compass
/// - Generating new snapshots
/// - Marking compass steps as completed
class CompassBloc extends Bloc<CompassEvent, CompassState> {
  final GenerateDailySnapshotUseCase generateDailySnapshot;
  final DailyCompassRepository compassRepository;

  CompassBloc({
    required this.generateDailySnapshot,
    required this.compassRepository,
  }) : super(const CompassInitial()) {
    on<LoadCompassEvent>(_onLoadCompass);
    on<GenerateSnapshotEvent>(_onGenerateSnapshot);
    on<MarkCompassCompletedEvent>(_onMarkCompassCompleted);
    on<RefreshCompassEvent>(_onRefresh);
  }

  /// Handle LoadCompassEvent
  Future<void> _onLoadCompass(
    LoadCompassEvent event,
    Emitter<CompassState> emit,
  ) async {
    emit(const CompassLoading());

    // Try to get existing snapshot for today
    final existingResult = await generateDailySnapshot.getTodaySnapshotIfExists();

    await existingResult.fold(
      (failure) async {
        emit(CompassError(message: failure.message));
      },
      (result) async {
        if (result != null) {
          // Existing snapshot found
          emit(CompassLoaded(
            snapshot: result.snapshot,
            compass: result.compass,
          ));
        } else {
          // No snapshot for today, generate new one
          add(const GenerateSnapshotEvent());
        }
      },
    );
  }

  /// Handle GenerateSnapshotEvent
  Future<void> _onGenerateSnapshot(
    GenerateSnapshotEvent event,
    Emitter<CompassState> emit,
  ) async {
    emit(const CompassLoading());

    final result = await generateDailySnapshot(const NoParams());

    result.fold(
      (failure) {
        // If it's a data-related failure, show empty state
        if (failure.message.contains('Failed to collect')) {
          emit(const CompassEmpty(
            message: 'Belum ada data keuangan. Mari mulai dengan menambahkan akun dan pengeluaran bulananmu.',
          ));
        } else {
          emit(CompassError(message: failure.message));
        }
      },
      (snapshotResult) {
        // Check if this is first time (all values are 0)
        final isFirstTime = snapshotResult.snapshot.burnRate == 0 &&
            snapshotResult.snapshot.totalLiquidAssets == 0;

        emit(CompassLoaded(
          snapshot: snapshotResult.snapshot,
          compass: snapshotResult.compass,
          isFirstTimeUser: isFirstTime,
        ));
      },
    );
  }

  /// Handle MarkCompassCompletedEvent
  Future<void> _onMarkCompassCompleted(
    MarkCompassCompletedEvent event,
    Emitter<CompassState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CompassLoaded) return;

    final result = await compassRepository.markTodayCompleted(notes: event.notes);

    result.fold(
      (failure) {
        // Don't change state on failure, just log
        // In production, we might want to show a snackbar
      },
      (_) {
        // Update state with completed compass
        final updatedCompass = currentState.compass.markCompleted();
        emit(currentState.copyWithCompass(updatedCompass));
      },
    );
  }

  /// Handle RefreshCompassEvent
  Future<void> _onRefresh(
    RefreshCompassEvent event,
    Emitter<CompassState> emit,
  ) async {
    // Force regenerate snapshot
    add(const GenerateSnapshotEvent());
  }
}
