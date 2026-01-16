import 'package:equatable/equatable.dart';

/// Transaction type
enum TransactionType {
  income('income', 'Pemasukan'),
  expense('expense', 'Pengeluaran');

  final String code;
  final String nameId;

  const TransactionType(this.code, this.nameId);

  static TransactionType fromCode(String code) {
    return TransactionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Transaction entity - represents a money movement
class Transaction extends Equatable {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final String accountId;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.accountId,
    required this.createdAt,
  });

  /// Is this a passive income transaction
  bool get isPassiveIncome {
    if (type != TransactionType.income) return false;
    return ['investment', 'rental', 'dividend', 'interest'].contains(category);
  }

  /// Is this a salary income
  bool get isSalaryIncome {
    if (type != TransactionType.income) return false;
    return category == 'salary';
  }

  /// Is this an essential expense
  bool get isEssentialExpense {
    if (type != TransactionType.expense) return false;
    return [
      'housing',
      'utilities',
      'groceries',
      'transportation',
      'healthcare',
      'insurance',
      'debt_payment',
    ].contains(category);
  }

  @override
  List<Object?> get props => [
        id,
        date,
        description,
        amount,
        type,
        category,
        accountId,
        createdAt,
      ];
}
