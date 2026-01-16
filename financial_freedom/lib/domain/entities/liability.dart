import 'package:equatable/equatable.dart';

/// Liability entity - represents debts and obligations
class Liability extends Equatable {
  final String id;
  final String name;
  final double remainingBalance;
  final double monthlyPayment;
  final double? interestRate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Liability({
    required this.id,
    required this.name,
    required this.remainingBalance,
    required this.monthlyPayment,
    this.interestRate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Months remaining to pay off (approximate)
  double get monthsRemaining {
    if (monthlyPayment <= 0) return double.infinity;
    return remainingBalance / monthlyPayment;
  }

  /// Years remaining to pay off
  double get yearsRemaining => monthsRemaining / 12;

  @override
  List<Object?> get props => [
        id,
        name,
        remainingBalance,
        monthlyPayment,
        interestRate,
        notes,
        createdAt,
        updatedAt,
      ];
}
