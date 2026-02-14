import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/domain/entities/account.dart';
import 'package:financial_freedom/ui/bloc/onboarding/account_setup_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

class ManageAccountsPage extends StatelessWidget {
  const ManageAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountSetupBloc>(
      create: (_) => getIt<AccountSetupBloc>()..add(const LoadAccountsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Akun Keuangan'),
          centerTitle: true,
        ),
        body: BlocBuilder<AccountSetupBloc, AccountSetupState>(
          builder: (context, state) {
            if (state is AccountSetupLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountSetupError) {
              return Center(child: Text(state.message));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet, size: 40, color: Colors.green),
                          const SizedBox(height: 12),
                          Text(
                            'Kelola Akun Keuanganmu',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tambah, hapus, atau perbarui akun keuanganmu.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account list
                  if (state.accounts.isNotEmpty) ...[
                    _AccountListSection(accounts: state.accounts),
                    const SizedBox(height: 16),
                  ],

                  // Add form
                  _AddAccountForm(),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccountListSection extends StatelessWidget {
  final List<Account> accounts;

  const _AccountListSection({required this.accounts});

  @override
  Widget build(BuildContext context) {
    final totalBalance = accounts.fold<double>(0, (sum, a) => sum + a.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Akun Keuanganmu:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Total: Rp ${_formatNumber(totalBalance)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...accounts.map((account) => _AccountTile(account: account)),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}Jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}Rb';
    return value.toStringAsFixed(0);
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;

  const _AccountTile({required this.account});

  IconData _getAccountIcon() {
    switch (account.type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.ewallet:
        return Icons.phone_android;
      case AccountType.investment:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getAccountIcon()),
        title: Text(account.name),
        subtitle: Text(account.type.nameId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${account.balance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (account.isLiquid)
                  Text(
                    'Likuid',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<AccountSetupBloc>().add(RemoveAccountEvent(account.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountForm extends StatefulWidget {
  @override
  State<_AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<_AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedType = AccountType.bank;
  bool _isLiquid = true;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final balance = double.tryParse(_balanceController.text) ?? 0;
      context.read<AccountSetupBloc>().add(
            AddAccountEvent(
              name: _nameController.text.trim(),
              type: _selectedType,
              balance: balance,
              isLiquid: _isLiquid,
            ),
          );
      _nameController.clear();
      _balanceController.clear();
      setState(() {
        _selectedType = AccountType.bank;
        _isLiquid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Akun Baru',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ConsciousTextField(
                label: 'Nama Akun',
                hint: 'contoh: BCA, GoPay, Dompet',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nama akun diperlukan';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Akun',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.nameId));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      if (value == AccountType.investment) _isLiquid = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CurrencyInputField(
                label: 'Saldo Saat Ini',
                hint: '0',
                controller: _balanceController,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final balance = double.tryParse(value);
                    if (balance == null || balance < 0) return 'Saldo tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isLiquid,
                onChanged: (value) => setState(() => _isLiquid = value ?? true),
                title: const Text('Akun Likuid'),
                subtitle: const Text('Uang yang bisa langsung dipakai kapan saja'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Akun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
