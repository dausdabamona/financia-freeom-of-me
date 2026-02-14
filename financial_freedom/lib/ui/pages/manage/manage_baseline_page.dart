import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/ui/bloc/onboarding/baseline_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

class ManageBaselinePage extends StatelessWidget {
  const ManageBaselinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BaselineBloc>(
      create: (_) => getIt<BaselineBloc>()..add(const LoadBaselineEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengeluaran Bulanan'),
          centerTitle: true,
        ),
        body: BlocConsumer<BaselineBloc, BaselineState>(
          listener: (context, state) {
            if (state is BaselineReady && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          },
          builder: (context, state) {
            if (state is BaselineLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BaselineError) {
              return Center(child: Text(state.message));
            }

            // MonthlyBaseline stores aggregated values (essentialCost, optionalCost, safetyBuffer)
            // not individual categories. Show current total for reference.
            double currentTotal = 0;
            if (state is BaselineReady && state.baseline != null) {
              currentTotal = state.baseline!.totalBaseline;
            }

            return _BaselineEditForm(currentTotal: currentTotal);
          },
        ),
      ),
    );
  }
}

class _BaselineEditForm extends StatefulWidget {
  final double currentTotal;

  const _BaselineEditForm({required this.currentTotal});

  @override
  State<_BaselineEditForm> createState() => _BaselineEditFormState();
}

class _BaselineEditFormState extends State<_BaselineEditForm> {
  final _housingController = TextEditingController();
  final _foodController = TextEditingController();
  final _transportController = TextEditingController();
  final _healthController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _debtController = TextEditingController();
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _housingController.dispose();
    _foodController.dispose();
    _transportController.dispose();
    _healthController.dispose();
    _utilitiesController.dispose();
    _debtController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _updateBaseline() {
    context.read<BaselineBloc>().add(
          UpdateBaselineEvent(
            housing: double.tryParse(_housingController.text) ?? 0,
            food: double.tryParse(_foodController.text) ?? 0,
            transport: double.tryParse(_transportController.text) ?? 0,
            health: double.tryParse(_healthController.text) ?? 0,
            utilities: double.tryParse(_utilitiesController.text) ?? 0,
            debtPayments: double.tryParse(_debtController.text) ?? 0,
            other: double.tryParse(_otherController.text) ?? 0,
          ),
        );
  }

  double get _totalBaseline {
    return (double.tryParse(_housingController.text) ?? 0) +
        (double.tryParse(_foodController.text) ?? 0) +
        (double.tryParse(_transportController.text) ?? 0) +
        (double.tryParse(_healthController.text) ?? 0) +
        (double.tryParse(_utilitiesController.text) ?? 0) +
        (double.tryParse(_debtController.text) ?? 0) +
        (double.tryParse(_otherController.text) ?? 0);
  }

  void _save() {
    _updateBaseline();
    context.read<BaselineBloc>().add(const SaveBaselineEvent());
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} Juta';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} Ribu';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long, size: 40, color: Colors.orange),
                  const SizedBox(height: 12),
                  Text(
                    'Pengeluaran Bulanan Dasar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentTotal > 0
                        ? 'Baseline saat ini: Rp ${_formatNumber(widget.currentTotal)}/bln'
                        : 'Belum ada baseline. Isi kategori di bawah.',
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

          // Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _BaselineField(icon: Icons.home, label: 'Tempat Tinggal', hint: 'Kontrakan, kost, cicilan rumah', controller: _housingController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.restaurant, label: 'Makan & Minum', hint: 'Kebutuhan makan sehari-hari', controller: _foodController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.directions_car, label: 'Transportasi', hint: 'Bensin, ojol, transport umum', controller: _transportController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.bolt, label: 'Utilitas', hint: 'Listrik, air, internet, pulsa', controller: _utilitiesController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.medical_services, label: 'Kesehatan', hint: 'BPJS, obat rutin, asuransi', controller: _healthController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.credit_card, label: 'Cicilan Utang', hint: 'KTA, kartu kredit, pinjaman', controller: _debtController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.more_horiz, label: 'Lainnya', hint: 'Kebutuhan wajib lainnya', controller: _otherController, onChanged: _updateBaseline),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Kebutuhan Bulanan',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatNumber(_totalBaseline)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _totalBaseline > 0 ? _save : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Simpan Perubahan',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BaselineField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _BaselineField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: CurrencyInputField(
              label: label,
              hint: hint,
              controller: controller,
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
