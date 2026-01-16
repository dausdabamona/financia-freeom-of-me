import 'package:equatable/equatable.dart';

/// Liability types
enum LiabilityType {
  mortgage,
  carLoan,
  creditCard,
  personalLoan,
  other,
}

extension LiabilityTypeX on LiabilityType {
  String get nameId {
    switch (this) {
      case LiabilityType.mortgage:
        return 'KPR';
      case LiabilityType.carLoan:
        return 'Kredit Kendaraan';
      case LiabilityType.creditCard:
        return 'Kartu Kredit';
      case LiabilityType.personalLoan:
        return 'Pinjaman Pribadi';
      case LiabilityType.other:
        return 'Lainnya';
    }
  }
}

/// Liability entity - represents debts and obligations
class Liability extends Equatable {
  final String id;
  final String name;
  final LiabilityType type;
  final double remainingBalance;
  final double monthlyPayment;
  final double? interestRate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Liability({
    required this.id,
    required this.name,
    this.type = LiabilityType.other,
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
        type,
        remainingBalance,
        monthlyPayment,
        interestRate,
        notes,
        createdAt,
        updatedAt,
      ];
}
