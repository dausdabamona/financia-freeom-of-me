import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/account.dart';
import 'package:financial_freedom/domain/usecases/save_account.dart';
import 'package:financial_freedom/domain/repositories/account_repository.dart';

// Events
abstract class AccountSetupEvent extends Equatable {
  const AccountSetupEvent();
  @override
  List<Object?> get props => [];
}

class LoadAccountsEvent extends AccountSetupEvent {
  const LoadAccountsEvent();
}

class AddAccountEvent extends AccountSetupEvent {
  final String name;
  final AccountType type;
  final double balance;
  final bool isLiquid;

  const AddAccountEvent({
    required this.name,
    required this.type,
    required this.balance,
    required this.isLiquid,
  });

  @override
  List<Object?> get props => [name, type, balance, isLiquid];
}

class RemoveAccountEvent extends AccountSetupEvent {
  final String accountId;

  const RemoveAccountEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class FinishAccountSetupEvent extends AccountSetupEvent {
  const FinishAccountSetupEvent();
}

// States
abstract class AccountSetupState extends Equatable {
  const AccountSetupState();

  // Default getters for UI consumption
  List<Account> get accounts => [];
  bool get isLoading => false;
  double get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);
  double get liquidBalance => accounts.where((a) => a.isLiquid).fold(0, (sum, a) => sum + a.balance);

  @override
  List<Object?> get props => [];
}

class AccountSetupInitial extends AccountSetupState {
  const AccountSetupInitial();
}

class AccountSetupLoading extends AccountSetupState {
  @override
  final List<Account> accounts;

  const AccountSetupLoading({this.accounts = const []});

  @override
  bool get isLoading => true;

  @override
  List<Object?> get props => [accounts];
}

class AccountSetupReady extends AccountSetupState {
  @override
  final List<Account> accounts;
  final String? message;

  const AccountSetupReady({
    required this.accounts,
    this.message,
  });

  @override
  double get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);
  @override
  double get liquidBalance => accounts.where((a) => a.isLiquid).fold(0, (sum, a) => sum + a.balance);

  @override
  List<Object?> get props => [accounts, message];
}

class AccountSetupError extends AccountSetupState {
  final String message;

  const AccountSetupError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountSetupCompleted extends AccountSetupState {
  final List<Account> accounts;

  const AccountSetupCompleted(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

// BLoC
class AccountSetupBloc extends Bloc<AccountSetupEvent, AccountSetupState> {
  final SaveAccount saveAccount;
  final AccountRepository accountRepository;

  AccountSetupBloc({
    required this.saveAccount,
    required this.accountRepository,
  }) : super(const AccountSetupInitial()) {
    on<LoadAccountsEvent>(_onLoadAccounts);
    on<AddAccountEvent>(_onAddAccount);
    on<RemoveAccountEvent>(_onRemoveAccount);
    on<FinishAccountSetupEvent>(_onFinishSetup);
  }

  Future<void> _onLoadAccounts(
    LoadAccountsEvent event,
    Emitter<AccountSetupState> emit,
  ) async {
    emit(const AccountSetupLoading());

    final result = await accountRepository.getAllAccounts();
    result.fold(
      (failure) => emit(AccountSetupError(failure.message)),
      (accounts) => emit(AccountSetupReady(accounts: accounts)),
    );
  }

  Future<void> _onAddAccount(
    AddAccountEvent event,
    Emitter<AccountSetupState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountSetupReady) return;

    emit(AccountSetupLoading(accounts: currentState.accounts));

    final result = await saveAccount(SaveAccountParams(
      name: event.name,
      type: event.type,
      balance: event.balance,
      isLiquid: event.isLiquid,
    ));

    await result.fold(
      (failure) async {
        emit(AccountSetupReady(
          accounts: currentState.accounts,
          message: failure.message,
        ));
      },
      (_) async {
        // Reload accounts to get the new list
        final accountsResult = await accountRepository.getAllAccounts();
        accountsResult.fold(
          (failure) => emit(AccountSetupError(failure.message)),
          (accounts) => emit(AccountSetupReady(
            accounts: accounts,
            message: 'Akun berhasil ditambahkan',
          )),
        );
      },
    );
  }

  Future<void> _onRemoveAccount(
    RemoveAccountEvent event,
    Emitter<AccountSetupState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountSetupReady) return;

    emit(AccountSetupLoading(accounts: currentState.accounts));

    final result = await accountRepository.deleteAccount(event.accountId);

    await result.fold(
      (failure) async {
        emit(AccountSetupReady(
          accounts: currentState.accounts,
          message: failure.message,
        ));
      },
      (_) async {
        final accountsResult = await accountRepository.getAllAccounts();
        accountsResult.fold(
          (failure) => emit(AccountSetupError(failure.message)),
          (accounts) => emit(AccountSetupReady(
            accounts: accounts,
            message: 'Akun dihapus',
          )),
        );
      },
    );
  }

  Future<void> _onFinishSetup(
    FinishAccountSetupEvent event,
    Emitter<AccountSetupState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountSetupReady) return;

    emit(AccountSetupCompleted(currentState.accounts));
  }
}
