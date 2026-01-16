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

// States
abstract class TimeFreedomState extends Equatable {
  const TimeFreedomState();
  @override
  List<Object?> get props => [];
}

class TimeFreedomInitial extends TimeFreedomState {
  const TimeFreedomInitial();
}

class TimeFreedomLoading extends TimeFreedomState {
  const TimeFreedomLoading();
}

class TimeFreedomReady extends TimeFreedomState {
  final TimeProfile? profile;
  final String? message;

  const TimeFreedomReady({
    this.profile,
    this.message,
  });

  double get timeFreedomIndex => profile?.timeFreedomIndex ?? 0;
  double get timeFreedomPercent => profile?.timeFreedomPercent ?? 0;

  @override
  List<Object?> get props => [profile, message];
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

  Future<void> _onFinishSetup(
    FinishTimeSetupEvent event,
    Emitter<TimeFreedomState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TimeFreedomReady) return;

    emit(TimeFreedomCompleted(currentState.profile));
  }
}
