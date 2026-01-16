import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/accounts_table.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// Get all accounts
  Future<List<Account>> getAllAccounts() => select(accounts).get();

  /// Get account by id
  Future<Account?> getAccountById(int id) {
    return (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Get only liquid accounts
  Future<List<Account>> getLiquidAccounts() {
    return (select(accounts)..where((a) => a.isLiquid.equals(true))).get();
  }

  /// Get total balance of all liquid accounts
  Future<double> getTotalLiquidBalance() async {
    final liquidAccounts = await getLiquidAccounts();
    return liquidAccounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  /// Get total balance of all accounts
  Future<double> getTotalBalance() async {
    final allAccounts = await getAllAccounts();
    return allAccounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  /// Insert a new account
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Update an account
  Future<bool> updateAccount(Account account) {
    return update(accounts).replace(account);
  }

  /// Update account balance
  Future<int> updateBalance(int id, double newBalance) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete an account
  Future<int> deleteAccount(int id) {
    return (delete(accounts)..where((a) => a.id.equals(id))).go();
  }

  /// Watch all accounts
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();

  /// Watch liquid accounts
  Stream<List<Account>> watchLiquidAccounts() {
    return (select(accounts)..where((a) => a.isLiquid.equals(true))).watch();
  }
}
