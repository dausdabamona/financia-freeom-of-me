import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/domain/entities/asset.dart';
import 'package:financial_freedom/ui/bloc/onboarding/asset_liability_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

class ManageAssetsPage extends StatelessWidget {
  const ManageAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssetLiabilityBloc>(
      create: (_) => getIt<AssetLiabilityBloc>()..add(const LoadAssetsLiabilitiesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aset'),
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
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.trending_up, size: 40, color: Colors.blue),
                          const SizedBox(height: 12),
                          Text(
                            'Kelola Asetmu',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aset yang menghasilkan income akan meningkatkan skor kebebasanmu.',
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

                  // Total
                  if (state.assets.isNotEmpty) ...[
                    _AssetSummary(assets: state.assets),
                    const SizedBox(height: 8),
                    ...state.assets.map((asset) => _AssetTile(asset: asset)),
                    const SizedBox(height: 16),
                  ],

                  // Add form
                  _AddAssetForm(),

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

class _AssetSummary extends StatelessWidget {
  final List<Asset> assets;

  const _AssetSummary({required this.assets});

  @override
  Widget build(BuildContext context) {
    final totalValue = assets.fold<double>(0, (sum, a) => sum + a.liquidValue);
    final totalIncome = assets.where((a) => a.producesIncome).fold<double>(0, (sum, a) => sum + a.monthlyIncome);

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Total Aset', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rp ${_formatNumber(totalValue)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text('Passive Income', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rp ${_formatNumber(totalIncome)}/bln',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.blue,
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

class _AssetTile extends StatelessWidget {
  final Asset asset;

  const _AssetTile({required this.asset});

  IconData _getAssetIcon() {
    switch (asset.type) {
      case AssetType.cash:
        return Icons.money;
      case AssetType.bankSavings:
        return Icons.account_balance;
      case AssetType.property:
        return Icons.home;
      case AssetType.businessOwnership:
        return Icons.business;
      case AssetType.deposit:
        return Icons.lock;
      case AssetType.mutualFund:
        return Icons.pie_chart;
      case AssetType.gold:
        return Icons.diamond;
      case AssetType.stock:
        return Icons.trending_up;
      case AssetType.insuranceCash:
        return Icons.shield;
      case AssetType.receivable:
        return Icons.request_quote;
      case AssetType.vehicle:
        return Icons.directions_car;
      case AssetType.collectible:
        return Icons.palette;
      case AssetType.furniture:
        return Icons.chair;
      case AssetType.valuables:
        return Icons.inventory;
      case AssetType.other:
        return Icons.more_horiz;
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
                'Income: Rp ${asset.monthlyIncome.toStringAsFixed(0)}/bln',
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
                context.read<AssetLiabilityBloc>().add(RemoveAssetEvent(asset.id));
              },
            ),
          ],
        ),
        isThreeLine: asset.monthlyIncome > 0,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}Jt';
    return value.toStringAsFixed(0);
  }
}

class _AddAssetForm extends StatefulWidget {
  @override
  State<_AddAssetForm> createState() => _AddAssetFormState();
}

class _AddAssetFormState extends State<_AddAssetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _incomeController = TextEditingController();
  AssetType _selectedType = AssetType.bankSavings;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final monthlyIncome = double.tryParse(_incomeController.text) ?? 0;
      context.read<AssetLiabilityBloc>().add(
            AddAssetEvent(
              name: _nameController.text.trim(),
              type: _selectedType,
              liquidValue: double.tryParse(_valueController.text) ?? 0,
              producesIncome: monthlyIncome > 0,
              monthlyIncome: monthlyIncome,
            ),
          );
      _nameController.clear();
      _valueController.clear();
      _incomeController.clear();
      setState(() => _selectedType = AssetType.bankSavings);
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ConsciousTextField(
                label: 'Nama Aset',
                hint: 'contoh: Rumah, Mobil, Saham',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nama aset diperlukan';
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
                  return DropdownMenuItem(value: type, child: Text(type.nameId));
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
