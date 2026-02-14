import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/domain/entities/liability.dart';
import 'package:financial_freedom/ui/bloc/onboarding/asset_liability_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

class ManageLiabilitiesPage extends StatelessWidget {
  const ManageLiabilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssetLiabilityBloc>(
      create: (_) => getIt<AssetLiabilityBloc>()..add(const LoadAssetsLiabilitiesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Utang'),
          centerTitle: true,
        ),
        body: BlocBuilder<AssetLiabilityBloc, AssetLiabilityState>(
          builder: (context, state) {
            if (state is AssetLiabilityLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AssetLiabilityError) {
              return Center(child: Text(state.message));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.trending_down, size: 40, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            'Kelola Utangmu',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mengetahui beban utang adalah langkah pertama untuk bebas darinya.',
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

                  // Summary + list
                  if (state.liabilities.isNotEmpty) ...[
                    _LiabilitySummary(liabilities: state.liabilities),
                    const SizedBox(height: 8),
                    ...state.liabilities.map((l) => _LiabilityTile(liability: l)),
                    const SizedBox(height: 16),
                  ],

                  // Add form
                  _AddLiabilityForm(),

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

class _LiabilitySummary extends StatelessWidget {
  final List<Liability> liabilities;

  const _LiabilitySummary({required this.liabilities});

  @override
  Widget build(BuildContext context) {
    final totalBalance = liabilities.fold<double>(0, (sum, l) => sum + l.remainingBalance);
    final totalPayment = liabilities.fold<double>(0, (sum, l) => sum + l.monthlyPayment);

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Total Utang', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rp ${_formatNumber(totalBalance)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text('Cicilan/bln', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rp ${_formatNumber(totalPayment)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}Jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}Rb';
    return value.toStringAsFixed(0);
  }
}

class _LiabilityTile extends StatelessWidget {
  final Liability liability;

  const _LiabilityTile({required this.liability});

  IconData _getLiabilityIcon() {
    switch (liability.type) {
      case LiabilityType.mortgage:
        return Icons.home;
      case LiabilityType.carLoan:
        return Icons.directions_car;
      case LiabilityType.creditCard:
        return Icons.credit_card;
      case LiabilityType.personalLoan:
        return Icons.money;
      case LiabilityType.other:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getLiabilityIcon(), color: Colors.red),
        title: Text(liability.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(liability.type.nameId),
            Text(
              'Cicilan: Rp ${liability.monthlyPayment.toStringAsFixed(0)}/bln',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rp ${_formatNumber(liability.remainingBalance)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<AssetLiabilityBloc>().add(RemoveLiabilityEvent(liability.id));
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}Jt';
    return value.toStringAsFixed(0);
  }
}

class _AddLiabilityForm extends StatefulWidget {
  @override
  State<_AddLiabilityForm> createState() => _AddLiabilityFormState();
}

class _AddLiabilityFormState extends State<_AddLiabilityForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _paymentController = TextEditingController();
  final _interestController = TextEditingController();
  LiabilityType _selectedType = LiabilityType.personalLoan;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _paymentController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AssetLiabilityBloc>().add(
            AddLiabilityEvent(
              name: _nameController.text.trim(),
              type: _selectedType,
              remainingBalance: double.tryParse(_balanceController.text) ?? 0,
              monthlyPayment: double.tryParse(_paymentController.text) ?? 0,
              interestRate: double.tryParse(_interestController.text) ?? 0,
            ),
          );
      _nameController.clear();
      _balanceController.clear();
      _paymentController.clear();
      _interestController.clear();
      setState(() => _selectedType = LiabilityType.personalLoan);
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
                'Tambah Utang',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ConsciousTextField(
                label: 'Nama Utang',
                hint: 'contoh: KPR BCA, Pinjol A',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nama utang diperlukan';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LiabilityType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Utang',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: LiabilityType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.nameId));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              CurrencyInputField(
                label: 'Sisa Pokok Utang',
                helperText: 'Berapa yang masih harus dilunasi',
                controller: _balanceController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Sisa utang diperlukan';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CurrencyInputField(
                label: 'Cicilan per Bulan',
                helperText: 'Berapa yang kamu bayar tiap bulan',
                controller: _paymentController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Cicilan bulanan diperlukan';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ConsciousTextField(
                label: 'Bunga per Tahun (%) - Opsional',
                hint: '12',
                controller: _interestController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Utang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
