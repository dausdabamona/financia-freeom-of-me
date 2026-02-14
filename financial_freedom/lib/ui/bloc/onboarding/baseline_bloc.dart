import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/monthly_baseline.dart';
import 'package:financial_freedom/domain/usecases/save_baseline.dart';
import 'package:financial_freedom/domain/repositories/monthly_baseline_repository.dart';

// Events
abstract class BaselineEvent extends Equatable {
  const BaselineEvent();
  @override
  List<Object?> get props => [];
}

class LoadBaselineEvent extends BaselineEvent {
  const LoadBaselineEvent();
}

class SaveBaselineDataEvent extends BaselineEvent {
  final double essentialCost;
  final double optionalCost;
  final double safetyBuffer;
  final String? notes;

  const SaveBaselineDataEvent({
    required this.essentialCost,
    required this.optionalCost,
    required this.safetyBuffer,
    this.notes,
  });

  @override
  List<Object?> get props => [essentialCost, optionalCost, safetyBuffer, notes];
}

class FinishBaselineSetupEvent extends BaselineEvent {
  const FinishBaselineSetupEvent();
}

class SaveBaselineEvent extends BaselineEvent {
  const SaveBaselineEvent();
}

class UpdateBaselineEvent extends BaselineEvent {
  // Sesuai format Income Statement
  final double rent;             // 1. Sewa / Angsuran
  final double household;        // 2. Biaya Rumah Tangga
  final double transportation;   // 3. Biaya Transport
  final double insurance;        // 4. Asuransi
  final double incomeTax;        // 5. Pajak Penghasilan
  final double propertyTax;      // 6. Pajak Property
  final double personalPleasure; // 7. Kesenangan Pribadi
  final double familyRecreation; // 8. Rekreasi Keluarga
  final double gifts;            // 9. Hadiah
  final double education;        // 10. Pendidikan
  final double maintenance;      // 11. Perbaikan & Maintenance
  final double householdStaff;   // 12. Gaji Pegawai RT
  final double membership;       // 13. Keanggotaan Club
  final double healthcare;       // 14. Kesehatan
  final double socialContribution; // 15. Kontribusi Sosial
  final double other;            // 16. Lainnya

  const UpdateBaselineEvent({
    required this.rent,
    required this.household,
    required this.transportation,
    required this.insurance,
    required this.incomeTax,
    required this.propertyTax,
    required this.personalPleasure,
    required this.familyRecreation,
    required this.gifts,
    required this.education,
    required this.maintenance,
    required this.householdStaff,
    required this.membership,
    required this.healthcare,
    required this.socialContribution,
    required this.other,
  });

  @override
  List<Object?> get props => [
    rent, household, transportation, insurance, incomeTax, propertyTax,
    personalPleasure, familyRecreation, gifts, education, maintenance,
    householdStaff, membership, healthcare, socialContribution, other,
  ];
}

// States
abstract class BaselineState extends Equatable {
  const BaselineState();

  // Default getters for UI consumption
  double get rent => 0;
  double get household => 0;
  double get transportation => 0;
  double get insurance => 0;
  double get incomeTax => 0;
  double get propertyTax => 0;
  double get personalPleasure => 0;
  double get familyRecreation => 0;
  double get gifts => 0;
  double get education => 0;
  double get maintenance => 0;
  double get householdStaff => 0;
  double get membership => 0;
  double get healthcare => 0;
  double get socialContribution => 0;
  double get other => 0;

  double get totalBaseline =>
      rent + household + transportation + insurance + incomeTax + propertyTax +
      personalPleasure + familyRecreation + gifts + education + maintenance +
      householdStaff + membership + healthcare + socialContribution + other;
  bool get isLoading => false;

  @override
  List<Object?> get props => [];
}

class BaselineInitial extends BaselineState {
  const BaselineInitial();
}

class BaselineLoading extends BaselineState {
  const BaselineLoading();

  @override
  bool get isLoading => true;
}

class BaselineEditing extends BaselineState {
  @override
  final double rent;
  @override
  final double household;
  @override
  final double transportation;
  @override
  final double insurance;
  @override
  final double incomeTax;
  @override
  final double propertyTax;
  @override
  final double personalPleasure;
  @override
  final double familyRecreation;
  @override
  final double gifts;
  @override
  final double education;
  @override
  final double maintenance;
  @override
  final double householdStaff;
  @override
  final double membership;
  @override
  final double healthcare;
  @override
  final double socialContribution;
  @override
  final double other;

  const BaselineEditing({
    required this.rent,
    required this.household,
    required this.transportation,
    required this.insurance,
    required this.incomeTax,
    required this.propertyTax,
    required this.personalPleasure,
    required this.familyRecreation,
    required this.gifts,
    required this.education,
    required this.maintenance,
    required this.householdStaff,
    required this.membership,
    required this.healthcare,
    required this.socialContribution,
    required this.other,
  });

  @override
  List<Object?> get props => [
    rent, household, transportation, insurance, incomeTax, propertyTax,
    personalPleasure, familyRecreation, gifts, education, maintenance,
    householdStaff, membership, healthcare, socialContribution, other,
  ];
}

class BaselineReady extends BaselineState {
  final MonthlyBaseline? baseline;
  final String? message;

  const BaselineReady({
    this.baseline,
    this.message,
  });

  @override
  double get totalBaseline => baseline?.totalBaseline ?? 0;

  @override
  List<Object?> get props => [baseline, message];
}

class BaselineError extends BaselineState {
  final String message;

  const BaselineError(this.message);

  @override
  List<Object?> get props => [message];
}

class BaselineCompleted extends BaselineState {
  final MonthlyBaseline? baseline;

  const BaselineCompleted(this.baseline);

  @override
  List<Object?> get props => [baseline];
}

// BLoC
class BaselineBloc extends Bloc<BaselineEvent, BaselineState> {
  final SaveBaseline saveBaseline;
  final MonthlyBaselineRepository baselineRepository;

  BaselineBloc({
    required this.saveBaseline,
    required this.baselineRepository,
  }) : super(const BaselineInitial()) {
    on<LoadBaselineEvent>(_onLoadBaseline);
    on<SaveBaselineDataEvent>(_onSaveBaseline);
    on<UpdateBaselineEvent>(_onUpdateBaseline);
    on<SaveBaselineEvent>(_onSaveBaselineFromState);
    on<FinishBaselineSetupEvent>(_onFinishSetup);
  }

  Future<void> _onLoadBaseline(
    LoadBaselineEvent event,
    Emitter<BaselineState> emit,
  ) async {
    emit(const BaselineLoading());

    final result = await baselineRepository.getLatestBaseline();
    result.fold(
      (failure) => emit(BaselineError(failure.message)),
      (baseline) => emit(BaselineReady(baseline: baseline)),
    );
  }

  Future<void> _onSaveBaseline(
    SaveBaselineDataEvent event,
    Emitter<BaselineState> emit,
  ) async {
    emit(const BaselineLoading());

    final result = await saveBaseline(SaveBaselineParams(
      essentialCost: event.essentialCost,
      optionalCost: event.optionalCost,
      safetyBuffer: event.safetyBuffer,
      notes: event.notes,
    ));

    await result.fold(
      (failure) async {
        emit(BaselineReady(message: failure.message));
      },
      (_) async {
        final baselineResult = await baselineRepository.getLatestBaseline();
        baselineResult.fold(
          (failure) => emit(BaselineError(failure.message)),
          (baseline) => emit(BaselineReady(
            baseline: baseline,
            message: 'Baseline berhasil disimpan',
          )),
        );
      },
    );
  }

  void _onUpdateBaseline(
    UpdateBaselineEvent event,
    Emitter<BaselineState> emit,
  ) {
    emit(BaselineEditing(
      rent: event.rent,
      household: event.household,
      transportation: event.transportation,
      insurance: event.insurance,
      incomeTax: event.incomeTax,
      propertyTax: event.propertyTax,
      personalPleasure: event.personalPleasure,
      familyRecreation: event.familyRecreation,
      gifts: event.gifts,
      education: event.education,
      maintenance: event.maintenance,
      householdStaff: event.householdStaff,
      membership: event.membership,
      healthcare: event.healthcare,
      socialContribution: event.socialContribution,
      other: event.other,
    ));
  }

  Future<void> _onSaveBaselineFromState(
    SaveBaselineEvent event,
    Emitter<BaselineState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BaselineEditing) return;

    emit(const BaselineLoading());

    // Essential: Sewa, Rumah Tangga, Transport, Asuransi, Pajak, Kesehatan, Pendidikan
    final essentialCost = currentState.rent + currentState.household +
        currentState.transportation + currentState.insurance +
        currentState.incomeTax + currentState.propertyTax +
        currentState.healthcare + currentState.education;

    // Optional: Kesenangan, Rekreasi, Hadiah, Maintenance, Pegawai RT, Club, Sosial, Lainnya
    final optionalCost = currentState.personalPleasure + currentState.familyRecreation +
        currentState.gifts + currentState.maintenance +
        currentState.householdStaff + currentState.membership +
        currentState.socialContribution + currentState.other;

    final result = await saveBaseline(SaveBaselineParams(
      essentialCost: essentialCost,
      optionalCost: optionalCost,
      safetyBuffer: 0,
    ));

    await result.fold(
      (failure) async {
        emit(BaselineEditing(
          rent: currentState.rent,
          household: currentState.household,
          transportation: currentState.transportation,
          insurance: currentState.insurance,
          incomeTax: currentState.incomeTax,
          propertyTax: currentState.propertyTax,
          personalPleasure: currentState.personalPleasure,
          familyRecreation: currentState.familyRecreation,
          gifts: currentState.gifts,
          education: currentState.education,
          maintenance: currentState.maintenance,
          householdStaff: currentState.householdStaff,
          membership: currentState.membership,
          healthcare: currentState.healthcare,
          socialContribution: currentState.socialContribution,
          other: currentState.other,
        ));
      },
      (_) async {
        final baselineResult = await baselineRepository.getLatestBaseline();
        baselineResult.fold(
          (failure) => emit(BaselineError(failure.message)),
          (baseline) => emit(BaselineReady(
            baseline: baseline,
            message: 'Baseline berhasil disimpan',
          )),
        );
      },
    );
  }

  Future<void> _onFinishSetup(
    FinishBaselineSetupEvent event,
    Emitter<BaselineState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BaselineReady) return;

    emit(BaselineCompleted(currentState.baseline));
  }
}
