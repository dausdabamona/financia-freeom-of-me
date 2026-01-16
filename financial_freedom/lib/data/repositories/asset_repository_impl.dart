import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/asset.dart' as domain;
import 'package:financial_freedom/domain/repositories/asset_repository.dart';

/// Implementation of AssetRepository using Drift database
class AssetRepositoryImpl implements AssetRepository {
  final AppDatabase _database;

  AssetRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<domain.Asset>>> getAllAssets() async {
    try {
      final dbAssets = await _database.assetDao.getAllAssets();
      return Right(dbAssets.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get all assets: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Asset>> getAssetById(String id) async {
    try {
      final dbAsset = await _database.assetDao.getAssetById(int.parse(id));
      if (dbAsset == null) {
        return const Left(DatabaseFailure(message: 'Asset not found'));
      }
      return Right(_toDomain(dbAsset));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get asset: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Asset>>> getIncomeProducingAssets() async {
    try {
      final dbAssets = await _database.assetDao.getIncomeProducingAssets();
      return Right(dbAssets.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get income-producing assets: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalLiquidValue() async {
    try {
      final value = await _database.assetDao.getTotalLiquidValue();
      return Right(value);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total liquid value: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMonthlyPassiveIncome() async {
    try {
      final income = await _database.assetDao.getTotalMonthlyPassiveIncome();
      return Right(income);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total passive income: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAsset(domain.Asset asset) async {
    try {
      final companion = AssetsCompanion(
        name: Value(asset.name),
        liquidValue: Value(asset.liquidValue),
        producesIncome: Value(asset.producesIncome),
        monthlyIncome: Value(asset.monthlyIncome),
        notes: Value(asset.notes),
      );
      await _database.assetDao.insertAsset(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to save asset: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAsset(domain.Asset asset) async {
    try {
      final dbAsset = Asset(
        id: int.parse(asset.id),
        name: asset.name,
        liquidValue: asset.liquidValue,
        producesIncome: asset.producesIncome,
        monthlyIncome: asset.monthlyIncome,
        notes: asset.notes,
        createdAt: asset.createdAt,
        updatedAt: DateTime.now(),
      );
      await _database.assetDao.updateAsset(dbAsset);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update asset: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAsset(String assetId) async {
    try {
      await _database.assetDao.deleteAsset(int.parse(assetId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete asset: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Asset>>> watchAllAssets() {
    return _database.assetDao.watchAllAssets().map((dbAssets) {
      try {
        return Right<Failure, List<domain.Asset>>(
          dbAssets.map(_toDomain).toList(),
        );
      } catch (e) {
        return Left<Failure, List<domain.Asset>>(
          DatabaseFailure(message: 'Failed to watch assets: $e'),
        );
      }
    });
  }

  domain.Asset _toDomain(Asset dbAsset) {
    return domain.Asset(
      id: dbAsset.id.toString(),
      name: dbAsset.name,
      type: domain.AssetType.values.firstWhere(
        (t) => t.name == dbAsset.type,
        orElse: () => domain.AssetType.other,
      ),
      currentValue: dbAsset.liquidValue,
      liquidValue: dbAsset.liquidValue,
      producesIncome: dbAsset.producesIncome,
      monthlyIncome: dbAsset.monthlyIncome,
      notes: dbAsset.notes,
      createdAt: dbAsset.createdAt,
      updatedAt: dbAsset.updatedAt,
    );
  }
}
