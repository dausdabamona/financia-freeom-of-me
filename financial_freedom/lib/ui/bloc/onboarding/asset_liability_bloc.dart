import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/asset.dart';
import 'package:financial_freedom/domain/entities/liability.dart';
import 'package:financial_freedom/domain/usecases/save_asset.dart';
import 'package:financial_freedom/domain/usecases/save_liability.dart';
import 'package:financial_freedom/domain/repositories/asset_repository.dart';
import 'package:financial_freedom/domain/repositories/liability_repository.dart';

// Events
abstract class AssetLiabilityEvent extends Equatable {
  const AssetLiabilityEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssetsLiabilitiesEvent extends AssetLiabilityEvent {
  const LoadAssetsLiabilitiesEvent();
}

class LoadAssetsEvent extends AssetLiabilityEvent {
  const LoadAssetsEvent();
}

class LoadLiabilitiesEvent extends AssetLiabilityEvent {
  const LoadLiabilitiesEvent();
}

class FinishAssetLiabilityEvent extends AssetLiabilityEvent {
  const FinishAssetLiabilityEvent();
}

class AddAssetEvent extends AssetLiabilityEvent {
  final String name;
  final AssetType type;
  final double liquidValue;
  final bool producesIncome;
  final double monthlyIncome;
  final String? notes;

  const AddAssetEvent({
    required this.name,
    required this.type,
    required this.liquidValue,
    required this.producesIncome,
    required this.monthlyIncome,
    this.notes,
  });

  @override
  List<Object?> get props => [name, type, liquidValue, producesIncome, monthlyIncome, notes];
}

class RemoveAssetEvent extends AssetLiabilityEvent {
  final String assetId;

  const RemoveAssetEvent(this.assetId);

  @override
  List<Object?> get props => [assetId];
}

class AddLiabilityEvent extends AssetLiabilityEvent {
  final String name;
  final LiabilityType type;
  final double remainingBalance;
  final double monthlyPayment;
  final double? interestRate;
  final String? notes;

  const AddLiabilityEvent({
    required this.name,
    required this.type,
    required this.remainingBalance,
    required this.monthlyPayment,
    this.interestRate,
    this.notes,
  });

  @override
  List<Object?> get props => [name, type, remainingBalance, monthlyPayment, interestRate, notes];
}

class RemoveLiabilityEvent extends AssetLiabilityEvent {
  final String liabilityId;

  const RemoveLiabilityEvent(this.liabilityId);

  @override
  List<Object?> get props => [liabilityId];
}

class FinishAssetLiabilitySetupEvent extends AssetLiabilityEvent {
  const FinishAssetLiabilitySetupEvent();
}

// States
abstract class AssetLiabilityState extends Equatable {
  const AssetLiabilityState();

  // Default getters for UI consumption
  List<Asset> get assets => [];
  List<Liability> get liabilities => [];
  bool get isLoading => false;
  double get totalAssetValue => assets.fold(0, (sum, a) => sum + a.liquidValue);
  double get totalLiabilityBalance => liabilities.fold(0, (sum, l) => sum + l.remainingBalance);
  double get totalMonthlyPassiveIncome =>
      assets.where((a) => a.producesIncome).fold(0, (sum, a) => sum + a.monthlyIncome);
  double get totalMonthlyDebtPayment => liabilities.fold(0, (sum, l) => sum + l.monthlyPayment);
  double get netWorth => totalAssetValue - totalLiabilityBalance;

  @override
  List<Object?> get props => [];
}

class AssetLiabilityInitial extends AssetLiabilityState {
  const AssetLiabilityInitial();
}

class AssetLiabilityLoading extends AssetLiabilityState {
  const AssetLiabilityLoading();

  @override
  bool get isLoading => true;
}

class AssetLiabilityReady extends AssetLiabilityState {
  @override
  final List<Asset> assets;
  @override
  final List<Liability> liabilities;
  final String? message;

  const AssetLiabilityReady({
    required this.assets,
    required this.liabilities,
    this.message,
  });

  @override
  double get totalAssetValue => assets.fold(0, (sum, a) => sum + a.liquidValue);
  @override
  double get totalMonthlyPassiveIncome =>
      assets.where((a) => a.producesIncome).fold(0, (sum, a) => sum + a.monthlyIncome);
  @override
  double get totalLiabilityBalance => liabilities.fold(0, (sum, l) => sum + l.remainingBalance);
  @override
  double get totalMonthlyDebtPayment => liabilities.fold(0, (sum, l) => sum + l.monthlyPayment);
  @override
  double get netWorth => totalAssetValue - totalLiabilityBalance;

  @override
  List<Object?> get props => [assets, liabilities, message];
}

class AssetLiabilityError extends AssetLiabilityState {
  final String message;

  const AssetLiabilityError(this.message);

  @override
  List<Object?> get props => [message];
}

class AssetLiabilityCompleted extends AssetLiabilityState {
  final List<Asset> assets;
  final List<Liability> liabilities;

  const AssetLiabilityCompleted({
    required this.assets,
    required this.liabilities,
  });

  @override
  List<Object?> get props => [assets, liabilities];
}

// BLoC
class AssetLiabilityBloc extends Bloc<AssetLiabilityEvent, AssetLiabilityState> {
  final SaveAsset saveAsset;
  final SaveLiability saveLiability;
  final AssetRepository assetRepository;
  final LiabilityRepository liabilityRepository;

  AssetLiabilityBloc({
    required this.saveAsset,
    required this.saveLiability,
    required this.assetRepository,
    required this.liabilityRepository,
  }) : super(const AssetLiabilityInitial()) {
    on<LoadAssetsLiabilitiesEvent>(_onLoad);
    on<LoadAssetsEvent>(_onLoadAssets);
    on<LoadLiabilitiesEvent>(_onLoadLiabilities);
    on<AddAssetEvent>(_onAddAsset);
    on<RemoveAssetEvent>(_onRemoveAsset);
    on<AddLiabilityEvent>(_onAddLiability);
    on<RemoveLiabilityEvent>(_onRemoveLiability);
    on<FinishAssetLiabilitySetupEvent>(_onFinishSetup);
    on<FinishAssetLiabilityEvent>(_onFinishAssetLiability);
  }

  Future<void> _onLoad(
    LoadAssetsLiabilitiesEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    emit(const AssetLiabilityLoading());

    final assetsResult = await assetRepository.getAllAssets();
    final liabilitiesResult = await liabilityRepository.getAllLiabilities();

    assetsResult.fold(
      (failure) => emit(AssetLiabilityError(failure.message)),
      (assets) {
        liabilitiesResult.fold(
          (failure) => emit(AssetLiabilityError(failure.message)),
          (liabilities) => emit(AssetLiabilityReady(
            assets: assets,
            liabilities: liabilities,
          )),
        );
      },
    );
  }

  Future<void> _onLoadAssets(
    LoadAssetsEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    // Just redirect to full load
    add(const LoadAssetsLiabilitiesEvent());
  }

  Future<void> _onLoadLiabilities(
    LoadLiabilitiesEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    // Just redirect to full load
    add(const LoadAssetsLiabilitiesEvent());
  }

  Future<void> _onAddAsset(
    AddAssetEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(const AssetLiabilityLoading());

    final result = await saveAsset(SaveAssetParams(
      name: event.name,
      liquidValue: event.liquidValue,
      producesIncome: event.producesIncome,
      monthlyIncome: event.monthlyIncome,
      notes: event.notes,
    ));

    await result.fold(
      (failure) async {
        emit(AssetLiabilityReady(
          assets: currentState.assets,
          liabilities: currentState.liabilities,
          message: failure.message,
        ));
      },
      (_) async {
        await _reload(emit, 'Aset berhasil ditambahkan');
      },
    );
  }

  Future<void> _onRemoveAsset(
    RemoveAssetEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(const AssetLiabilityLoading());

    final result = await assetRepository.deleteAsset(event.assetId);

    await result.fold(
      (failure) async {
        emit(AssetLiabilityReady(
          assets: currentState.assets,
          liabilities: currentState.liabilities,
          message: failure.message,
        ));
      },
      (_) async {
        await _reload(emit, 'Aset dihapus');
      },
    );
  }

  Future<void> _onAddLiability(
    AddLiabilityEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(const AssetLiabilityLoading());

    final result = await saveLiability(SaveLiabilityParams(
      name: event.name,
      remainingBalance: event.remainingBalance,
      monthlyPayment: event.monthlyPayment,
      interestRate: event.interestRate,
      notes: event.notes,
    ));

    await result.fold(
      (failure) async {
        emit(AssetLiabilityReady(
          assets: currentState.assets,
          liabilities: currentState.liabilities,
          message: failure.message,
        ));
      },
      (_) async {
        await _reload(emit, 'Hutang berhasil ditambahkan');
      },
    );
  }

  Future<void> _onRemoveLiability(
    RemoveLiabilityEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(const AssetLiabilityLoading());

    final result = await liabilityRepository.deleteLiability(event.liabilityId);

    await result.fold(
      (failure) async {
        emit(AssetLiabilityReady(
          assets: currentState.assets,
          liabilities: currentState.liabilities,
          message: failure.message,
        ));
      },
      (_) async {
        await _reload(emit, 'Hutang dihapus');
      },
    );
  }

  Future<void> _reload(Emitter<AssetLiabilityState> emit, String message) async {
    final assetsResult = await assetRepository.getAllAssets();
    final liabilitiesResult = await liabilityRepository.getAllLiabilities();

    assetsResult.fold(
      (failure) => emit(AssetLiabilityError(failure.message)),
      (assets) {
        liabilitiesResult.fold(
          (failure) => emit(AssetLiabilityError(failure.message)),
          (liabilities) => emit(AssetLiabilityReady(
            assets: assets,
            liabilities: liabilities,
            message: message,
          )),
        );
      },
    );
  }

  Future<void> _onFinishSetup(
    FinishAssetLiabilitySetupEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(AssetLiabilityCompleted(
      assets: currentState.assets,
      liabilities: currentState.liabilities,
    ));
  }

  Future<void> _onFinishAssetLiability(
    FinishAssetLiabilityEvent event,
    Emitter<AssetLiabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssetLiabilityReady) return;

    emit(AssetLiabilityCompleted(
      assets: currentState.assets,
      liabilities: currentState.liabilities,
    ));
  }
}
