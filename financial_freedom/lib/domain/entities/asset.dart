import 'package:equatable/equatable.dart';

/// Asset entity - represents owned assets that have value
class Asset extends Equatable {
  final String id;
  final String name;
  final double liquidValue;
  final bool producesIncome;
  final double monthlyIncome;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    required this.liquidValue,
    required this.producesIncome,
    required this.monthlyIncome,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Annual income from this asset
  double get annualIncome => monthlyIncome * 12;

  /// Yield percentage (if has value)
  double get yieldPercent {
    if (liquidValue <= 0) return 0;
    return (annualIncome / liquidValue) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        liquidValue,
        producesIncome,
        monthlyIncome,
        notes,
        createdAt,
        updatedAt,
      ];
}
