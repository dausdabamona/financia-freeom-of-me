import 'package:equatable/equatable.dart';

/// Asset types
enum AssetType {
  property,
  vehicle,
  investment,
  savings,
  other,
}

extension AssetTypeX on AssetType {
  String get nameId {
    switch (this) {
      case AssetType.property:
        return 'Properti';
      case AssetType.vehicle:
        return 'Kendaraan';
      case AssetType.investment:
        return 'Investasi';
      case AssetType.savings:
        return 'Tabungan';
      case AssetType.other:
        return 'Lainnya';
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
