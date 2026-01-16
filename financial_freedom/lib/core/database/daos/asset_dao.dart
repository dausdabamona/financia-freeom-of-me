import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/assets_table.dart';

part 'asset_dao.g.dart';

@DriftAccessor(tables: [Assets])
class AssetDao extends DatabaseAccessor<AppDatabase> with _$AssetDaoMixin {
  AssetDao(super.db);

  /// Get all assets
  Future<List<Asset>> getAllAssets() => select(assets).get();

  /// Get asset by id
  Future<Asset?> getAssetById(int id) {
    return (select(assets)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Get only income-producing assets
  Future<List<Asset>> getIncomeProducingAssets() {
    return (select(assets)..where((a) => a.producesIncome.equals(true))).get();
  }

  /// Get total liquid value of all assets
  Future<double> getTotalLiquidValue() async {
    final allAssets = await getAllAssets();
    return allAssets.fold<double>(0.0, (sum, asset) => sum + asset.liquidValue);
  }

  /// Get total monthly passive income from assets
  Future<double> getTotalMonthlyPassiveIncome() async {
    final incomeAssets = await getIncomeProducingAssets();
    return incomeAssets.fold<double>(0.0, (sum, asset) => sum + asset.monthlyIncome);
  }

  /// Insert a new asset
  Future<int> insertAsset(AssetsCompanion asset) {
    return into(assets).insert(asset);
  }

  /// Update an asset
  Future<bool> updateAsset(Asset asset) {
    return update(assets).replace(asset);
  }

  /// Delete an asset
  Future<int> deleteAsset(int id) {
    return (delete(assets)..where((a) => a.id.equals(id))).go();
  }

  /// Watch all assets
  Stream<List<Asset>> watchAllAssets() => select(assets).watch();

  /// Watch income-producing assets
  Stream<List<Asset>> watchIncomeProducingAssets() {
    return (select(assets)..where((a) => a.producesIncome.equals(true)))
        .watch();
  }
}
