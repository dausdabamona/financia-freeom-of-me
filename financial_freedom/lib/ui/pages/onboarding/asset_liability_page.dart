import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/domain/entities/asset.dart';
import 'package:financial_freedom/domain/entities/liability.dart';
import 'package:financial_freedom/ui/bloc/onboarding/asset_liability_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

/// Asset & Liability Page - Step 3 of Reality Entry
///
/// UX Philosophy: Understanding what you own and what you owe
/// "Apa yang kamu miliki? Apa yang menjadi bebanmu?"
class AssetLiabilityPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const AssetLiabilityPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetLiabilityBloc, AssetLiabilityState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Conscious header
              Padding(
                padding: const EdgeInsets.all(16),
                child: _ConsciousHeader(),
              ),

              // Tab bar
              TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.trending_up),
                    text: 'Aset (${state.assets.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.trending_down),
                    text: 'Utang (${state.liabilities.length})',
                  ),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _AssetTab(assets: state.assets),
                    _LiabilityTab(liabilities: state.liabilities),
                  ],
                ),
              ),

              // Net worth summary
              _NetWorthSummary(state: state),

              // Navigation
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context
                                    .read<AssetLiabilityBloc>()
                                    .add(const FinishAssetLiabilityEvent());
                                onContinue();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Lanjut ke Waktu'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Conscious header
class _ConsciousHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.balance, size: 40, color: Colors.purple),
            const SizedBox(height: 12),
            Text(
              'Apa yang kamu miliki? Apa yang menjadi bebanmu?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Langkah ini opsional, tapi membantu melihat gambaran lengkap.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Asset tab
class _AssetTab extends StatelessWidget {
  final List<Asset> assets;

  const _AssetTab({required this.assets});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Asset list
          if (assets.isNotEmpty) ...[
            ...assets.map((asset) => _AssetTile(asset: asset)),
            const SizedBox(height: 16),
          ],

          // Add asset form
          _AddAssetForm(),
        ],
      ),
    );
  }
}

/// Single asset tile
class _AssetTile extends StatelessWidget {
  final Asset asset;

  const _AssetTile({required this.asset});

  IconData _getAssetIcon() {
    switch (asset.type) {
      case AssetType.property:
        return Icons.home;
      case AssetType.vehicle:
        return Icons.directions_car;
      case AssetType.investment:
        return Icons.trending_up;
      case AssetType.savings:
        return Icons.savings;
      case AssetType.other:
        return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getAssetIcon(), color: Colors.green),
        title: Text(asset.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset.type.nameId),
            if (asset.monthlyIncome > 0)
              Text(
                'Penghasilan: Rp ${asset.monthlyIncome.toStringAsFixed(0)}/bln',
                style: TextStyle(color: Colors.green.shade700, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rp ${_formatNumber(asset.currentValue)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<AssetLiabilityBloc>().add(
                      RemoveAssetEvent(assetId: asset.id),
                    );
              },
            ),
          ],
        ),
        isThreeLine: asset.monthlyIncome > 0,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Jt';
    }
    return value.toStringAsFixed(0);
  }
}

/// Add asset form
class _AddAssetForm extends StatefulWidget {
  @override
  State<_AddAssetForm> createState() => _AddAssetFormState();
}

class _AddAssetFormState extends State<_AddAssetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _incomeController = TextEditingController();
  AssetType _selectedType = AssetType.savings;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AssetLiabilityBloc>().add(
            AddAssetEvent(
              name: _nameController.text.trim(),
              type: _selectedType,
              currentValue: double.tryParse(_valueController.text) ?? 0,
              monthlyIncome: double.tryParse(_incomeController.text) ?? 0,
            ),
          );

      _nameController.clear();
      _valueController.clear();
      _incomeController.clear();
      setState(() => _selectedType = AssetType.savings);
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
                'Tambah Aset',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ConsciousTextField(
                label: 'Nama Aset',
                hint: 'contoh: Rumah, Mobil, Saham',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama aset diperlukan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<AssetType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Aset',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: AssetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.nameId),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),

              CurrencyInputField(
                label: 'Nilai Saat Ini',
                helperText: 'Estimasi nilai jual',
                controller: _valueController,
              ),
              const SizedBox(height: 16),

              CurrencyInputField(
                label: 'Penghasilan Bulanan (Opsional)',
                helperText: 'Jika aset ini menghasilkan uang',
                controller: _incomeController,
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Aset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liability tab
class _LiabilityTab extends StatelessWidget {
  final List<Liability> liabilities;

  const _LiabilityTab({required this.liabilities});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Liability list
          if (liabilities.isNotEmpty) ...[
            ...liabilities.map((liability) => _LiabilityTile(liability: liability)),
            const SizedBox(height: 16),
          ],

          // Add liability form
          _AddLiabilityForm(),
        ],
      ),
    );
  }
}

/// Single liability tile
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<AssetLiabilityBloc>().add(
                      RemoveLiabilityEvent(liabilityId: liability.id),
                    );
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Jt';
    }
    return value.toStringAsFixed(0);
  }
}

/// Add liability form
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ConsciousTextField(
                label: 'Nama Utang',
                hint: 'contoh: KPR BCA, Pinjol A',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama utang diperlukan';
                  }
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
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.nameId),
                  );
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
                  if (value == null || value.isEmpty) {
                    return 'Sisa utang diperlukan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CurrencyInputField(
                label: 'Cicilan per Bulan',
                helperText: 'Berapa yang kamu bayar tiap bulan',
                controller: _paymentController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cicilan bulanan diperlukan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ConsciousTextField(
                label: 'Bunga per Tahun (%) - Opsional',
                hint: '12',
                controller: _interestController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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

/// Net worth summary
class _NetWorthSummary extends StatelessWidget {
  final AssetLiabilityState state;

  const _NetWorthSummary({required this.state});

  String _formatNumber(double value) {
    final absValue = value.abs();
    String formatted;
    if (absValue >= 1000000000) {
      formatted = '${(absValue / 1000000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000000) {
      formatted = '${(absValue / 1000000).toStringAsFixed(1)}Jt';
    } else if (absValue >= 1000) {
      formatted = '${(absValue / 1000).toStringAsFixed(1)}Rb';
    } else {
      formatted = absValue.toStringAsFixed(0);
    }
    return value < 0 ? '-Rp $formatted' : 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final netWorth = state.totalAssetValue - state.totalLiabilityBalance;
    final isPositive = netWorth >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Aset',
            value: 'Rp ${_formatNumberSimple(state.totalAssetValue)}',
            color: Colors.green,
          ),
          _SummaryItem(
            label: 'Total Utang',
            value: 'Rp ${_formatNumberSimple(state.totalLiabilityBalance)}',
            color: Colors.red,
          ),
          _SummaryItem(
            label: 'Net Worth',
            value: _formatNumber(netWorth),
            color: isPositive ? Colors.green : Colors.red,
            isBold: true,
          ),
        ],
      ),
    );
  }

  String _formatNumberSimple(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Jt';
    }
    return value.toStringAsFixed(0);
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
