import 'package:equatable/equatable.dart';

/// Events for CompassBloc
abstract class CompassEvent extends Equatable {
  const CompassEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's snapshot and compass
class LoadCompassEvent extends CompassEvent {
  const LoadCompassEvent();
}

/// Generate new snapshot for today
class GenerateSnapshotEvent extends CompassEvent {
  const GenerateSnapshotEvent();
}

/// Mark today's compass step as completed
class MarkCompassCompletedEvent extends CompassEvent {
  final String? notes;

  const MarkCompassCompletedEvent({this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Refresh data (re-generate snapshot)
class RefreshCompassEvent extends CompassEvent {
  const RefreshCompassEvent();
}
