import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/time_profile.dart';
import 'package:financial_freedom/domain/usecases/save_time_profile.dart';
import 'package:financial_freedom/domain/repositories/time_profile_repository.dart';

// Events
abstract class TimeFreedomEvent extends Equatable {
  const TimeFreedomEvent();
  @override
  List<Object?> get props => [];
}

class LoadTimeProfileEvent extends TimeFreedomEvent {
  const LoadTimeProfileEvent();
}

class SaveTimeDataEvent extends TimeFreedomEvent {
  final double workHoursPerWeek;
  final double obligationHoursPerWeek;
  final double freeHoursPerWeek;

  const SaveTimeDataEvent({
    required this.workHoursPerWeek,
    required this.obligationHoursPerWeek,
    required this.freeHoursPerWeek,
  });

  @override
  List<Object?> get props => [workHoursPerWeek, obligationHoursPerWeek, freeHoursPerWeek];
}

class FinishTimeSetupEvent extends TimeFreedomEvent {
  const FinishTimeSetupEvent();
}

class SaveTimeProfileEvent extends TimeFreedomEvent {
  const SaveTimeProfileEvent();
}

class UpdateTimeAllocationEvent extends TimeFreedomEvent {
  final double workHours;
  final double obligationHours;

  const UpdateTimeAllocationEvent({
    required this.workHours,
    required this.obligationHours,
  });

  @override
  List<Object?> get props => [workHours, obligationHours];
}

// States
abstract class TimeFreedomState extends Equatable {
  const TimeFreedomState();

  // Default getters for UI consumption
  double get workHours => 0;
  double get obligationHours => 0;
  double get freeHours => 0;
  double get totalHours => workHours + obligationHours + freeHours;
  bool get isValid => totalHours > 0 && totalHours <= 168;
  bool get isLoading => false;
  double get timeFreedomIndex => freeHours / 168;

  @override
  List<Object?> get props => [];
}

class TimeFreedomInitial extends TimeFreedomState {
  const TimeFreedomInitial();
}

class TimeFreedomLoading extends TimeFreedomState {
  const TimeFreedomLoading();

  @override
  bool get isLoading => true;
}

class TimeFreedomReady extends TimeFreedomState {
  final TimeProfile? profile;
  final String? message;

  const TimeFreedomReady({
    this.profile,
    this.message,
  });

  @override
  double get workHours => profile?.workHoursPerWeek ?? 0;

  @override
  double get obligationHours => profile?.obligationHoursPerWeek ?? 0;

  @override
  double get freeHours => profile?.freeHoursPerWeek ?? 0;

  @override
  double get timeFreedomIndex => profile?.timeFreedomIndex ?? 0;

  double get timeFreedomPercent => profile?.timeFreedomPercent ?? 0;

  @override
  bool get isValid => profile != null || (totalHours > 0 && totalHours <= 168);

  @override
  List<Object?> get props => [profile, message];
}

class TimeFreedomEditing extends TimeFreedomState {
  @override
  final double workHours;
  @override
  final double obligationHours;

  const TimeFreedomEditing({
    required this.workHours,
    required this.obligationHours,
  });

  @override
  double get freeHours {
    // 168 hours - sleep (56) - work - obligations = free hours
    final free = 168 - 56 - workHours - obligationHours;
    return free > 0 ? free : 0;
  }

  @override
  bool get isValid => workHours > 0 && totalHours <= 168;

  @override
  List<Object?> get props => [workHours, obligationHours];
}

class TimeFreedomError extends TimeFreedomState {
  final String message;

  const TimeFreedomError(this.message);

  @override
  List<Object?> get props => [message];
}

class TimeFreedomCompleted extends TimeFreedomState {
  final TimeProfile? profile;

  const TimeFreedomCompleted(this.profile);

  @override
  List<Object?> get props => [profile];
}

// BLoC
class TimeFreedomBloc extends Bloc<TimeFreedomEvent, TimeFreedomState> {
  final SaveTimeProfile saveTimeProfile;
  final TimeProfileRepository timeProfileRepository;

  TimeFreedomBloc({
    required this.saveTimeProfile,
    required this.timeProfileRepository,
  }) : super(const TimeFreedomInitial()) {
    on<LoadTimeProfileEvent>(_onLoadProfile);
    on<SaveTimeDataEvent>(_onSaveProfile);
    on<SaveTimeProfileEvent>(_onSaveProfileFromState);
    on<UpdateTimeAllocationEvent>(_onUpdateTimeAllocation);
    on<FinishTimeSetupEvent>(_onFinishSetup);
  }

  Future<void> _onLoadProfile(
    LoadTimeProfileEvent event,
    Emitter<TimeFreedomState> emit,
  ) async {
    emit(const TimeFreedomLoading());

    final result = await timeProfileRepository.getLatestProfile();
    result.fold(
      (failure) => emit(TimeFreedomError(failure.message)),
      (profile) => emit(TimeFreedomReady(profile: profile)),
    );
  }

  Future<void> _onSaveProfile(
    SaveTimeDataEvent event,
    Emitter<TimeFreedomState> emit,
  ) async {
    emit(const TimeFreedomLoading());

    final result = await saveTimeProfile(SaveTimeProfileParams(
      workHoursPerWeek: event.workHoursPerWeek,
      obligationHoursPerWeek: event.obligationHoursPerWeek,
      freeHoursPerWeek: event.freeHoursPerWeek,
    ));

    await result.fold(
      (failure) async {
        emit(TimeFreedomReady(message: failure.message));
      },
      (_) async {
        final profileResult = await timeProfileRepository.getLatestProfile();
        profileResult.fold(
          (failure) => emit(TimeFreedomError(failure.message)),
          (profile) => emit(TimeFreedomReady(
            profile: profile,
            message: 'Profil waktu berhasil disimpan',
          )),
        );
      },
    );
  }

  void _onUpdateTimeAllocation(
    UpdateTimeAllocationEvent event,
    Emitter<TimeFreedomState> emit,
  ) {
    emit(TimeFreedomEditing(
      workHours: event.workHours,
      obligationHours: event.obligationHours,
    ));
  }

  Future<void> _onSaveProfileFromState(
    SaveTimeProfileEvent event,
    Emitter<TimeFreedomState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TimeFreedomEditing) return;

    emit(const TimeFreedomLoading());

    final result = await saveTimeProfile(SaveTimeProfileParams(
      workHoursPerWeek: currentState.workHours,
      obligationHoursPerWeek: currentState.obligationHours,
      freeHoursPerWeek: currentState.freeHours,
    ));

    await result.fold(
      (failure) async {
        emit(TimeFreedomEditing(
          workHours: currentState.workHours,
          obligationHours: currentState.obligationHours,
        ));
      },
      (_) async {
        final profileResult = await timeProfileRepository.getLatestProfile();
        profileResult.fold(
          (failure) => emit(TimeFreedomError(failure.message)),
          (profile) => emit(TimeFreedomReady(
            profile: profile,
            message: 'Profil waktu berhasil disimpan',
          )),
        );
      },
    );
  }

  Future<void> _onFinishSetup(
    FinishTimeSetupEvent event,
    Emitter<TimeFreedomState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TimeFreedomReady) return;

    emit(TimeFreedomCompleted(currentState.profile));
  }
}
