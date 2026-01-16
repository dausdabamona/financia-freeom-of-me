import 'package:equatable/equatable.dart';

/// Account type enumeration
enum AccountType {
  cash('cash', 'Tunai'),
  bank('bank', 'Bank'),
  ewallet('ewallet', 'E-Wallet'),
  investment('investment', 'Investasi');

  final String code;
  final String nameId;

  const AccountType(this.code, this.nameId);

  static AccountType fromCode(String code) {
    return AccountType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AccountType.cash,
    );
  }
}

/// Account entity - represents a place where money is stored
class Account extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final bool isLiquid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.isLiquid,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        balance,
        isLiquid,
        createdAt,
        updatedAt,
      ];
}
