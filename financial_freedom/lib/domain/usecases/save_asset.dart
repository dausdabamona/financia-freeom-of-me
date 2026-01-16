import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/asset.dart';
import 'package:financial_freedom/domain/repositories/asset_repository.dart';

/// Parameters for SaveAsset use case
class SaveAssetParams extends Equatable {
  final String name;
  final double liquidValue;
  final bool producesIncome;
  final double monthlyIncome;
  final String? notes;

  const SaveAssetParams({
    required this.name,
    required this.liquidValue,
    required this.producesIncome,
    required this.monthlyIncome,
    this.notes,
  });

  @override
  List<Object?> get props => [name, liquidValue, producesIncome, monthlyIncome, notes];
}

/// Use case to save an asset
///
/// "Aset membebaskan waktumu."
class SaveAsset extends UseCase<void, SaveAssetParams> {
  final AssetRepository repository;

  SaveAsset(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveAssetParams params) async {
    // Validation
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'Nama aset tidak boleh kosong',
      ));
    }

    if (params.liquidValue < 0) {
      return const Left(ValidationFailure(
        message: 'Nilai aset tidak boleh negatif',
      ));
    }

    if (params.monthlyIncome < 0) {
      return const Left(ValidationFailure(
        message: 'Penghasilan bulanan tidak boleh negatif',
      ));
    }

    final now = DateTime.now();
    final asset = Asset(
      id: now.millisecondsSinceEpoch.toString(),
      name: params.name.trim(),
      currentValue: params.liquidValue,
      liquidValue: params.liquidValue,
      producesIncome: params.producesIncome,
      monthlyIncome: params.producesIncome ? params.monthlyIncome : 0,
      notes: params.notes,
      createdAt: now,
      updatedAt: now,
    );

    return repository.saveAsset(asset);
  }
}
