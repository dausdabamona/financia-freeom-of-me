import 'package:equatable/equatable.dart';

/// Asset types - berdasarkan format Balance Sheet
enum AssetType {
  cash,              // 1. Uang Cash
  bankSavings,       // 2. Saldo Bank / Tabungan
  property,          // 3. Property / Real Estate
  businessOwnership, // 4. Kepemilikan dalam Bisnis
  deposit,           // 5. Deposito
  mutualFund,        // 6. Reksa Dana
  gold,              // 7. Emas / Perak
  stock,             // 8. Saham
  insuranceCash,     // 9. Nilai Tunai Asuransi
  receivable,        // 10. Tagihan (Piutang)
  vehicle,           // 11. Kendaraan
  collectible,       // 12. Lukisan / Barang Antik
  furniture,         // 13. Furniture & Fixture
  valuables,         // 14. Barang Berharga Lain
  other,             // 15. Lainnya
}

extension AssetTypeX on AssetType {
  String get nameId {
    switch (this) {
      case AssetType.cash:
        return 'Uang Cash';
      case AssetType.bankSavings:
        return 'Saldo Bank / Tabungan';
      case AssetType.property:
        return 'Property / Real Estate';
      case AssetType.businessOwnership:
        return 'Kepemilikan Bisnis';
      case AssetType.deposit:
        return 'Deposito';
      case AssetType.mutualFund:
        return 'Reksa Dana';
      case AssetType.gold:
        return 'Emas / Perak';
      case AssetType.stock:
        return 'Saham';
      case AssetType.insuranceCash:
        return 'Nilai Tunai Asuransi';
      case AssetType.receivable:
        return 'Tagihan (Piutang)';
      case AssetType.vehicle:
        return 'Kendaraan';
      case AssetType.collectible:
        return 'Lukisan / Barang Antik';
      case AssetType.furniture:
        return 'Furniture & Fixture';
      case AssetType.valuables:
        return 'Barang Berharga Lain';
      case AssetType.other:
        return 'Lainnya';
    }
  }

  /// Whether this asset type is typically liquid (can be converted to cash quickly)
  bool get isTypicallyLiquid {
    switch (this) {
      case AssetType.cash:
      case AssetType.bankSavings:
      case AssetType.deposit:
      case AssetType.mutualFund:
      case AssetType.stock:
      case AssetType.gold:
        return true;
      default:
        return false;
    }
  }
}

/// Asset entity - represents owned assets that have value
class Asset extends Equatable {
  final String id;
  final String name;
  final AssetType type;
  final double currentValue;
  final double liquidValue;
  final bool producesIncome;
  final double monthlyIncome;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    this.type = AssetType.other,
    required this.currentValue,
    double? liquidValue,
    required this.producesIncome,
    required this.monthlyIncome,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : liquidValue = liquidValue ?? currentValue;

  /// Annual income from this asset
  double get annualIncome => monthlyIncome * 12;

  /// Yield percentage (if has value)
  double get yieldPercent {
    if (currentValue <= 0) return 0;
    return (annualIncome / currentValue) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        currentValue,
        liquidValue,
        producesIncome,
        monthlyIncome,
        notes,
        createdAt,
        updatedAt,
      ];
}
