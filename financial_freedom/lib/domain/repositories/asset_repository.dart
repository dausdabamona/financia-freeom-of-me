import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/asset.dart';

/// Repository contract for asset operations.
abstract class AssetRepository {
  /// Get all assets
  Future<Either<Failure, List<Asset>>> getAllAssets();

  /// Get asset by id
  Future<Either<Failure, Asset>> getAssetById(String id);

  /// Get only income-producing assets
  Future<Either<Failure, List<Asset>>> getIncomeProducingAssets();

  /// Get total liquid value of all assets
  Future<Either<Failure, double>> getTotalLiquidValue();

  /// Get total monthly passive income from assets
  Future<Either<Failure, double>> getTotalMonthlyPassiveIncome();

  /// Save a new asset
  Future<Either<Failure, void>> saveAsset(Asset asset);

  /// Update an existing asset
  Future<Either<Failure, void>> updateAsset(Asset asset);

  /// Delete an asset
  Future<Either<Failure, void>> deleteAsset(String assetId);

  /// Watch all assets for changes
  Stream<Either<Failure, List<Asset>>> watchAllAssets();
}
