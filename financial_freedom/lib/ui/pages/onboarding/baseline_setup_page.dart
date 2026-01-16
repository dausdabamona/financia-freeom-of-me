import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/ui/bloc/onboarding/baseline_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

/// Baseline Setup Page - Step 2 of Reality Entry
///
/// UX Philosophy: Understanding your survival costs
/// "Berapa yang kamu butuhkan untuk bertahan hidup setiap bulan?"
class BaselineSetupPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const BaselineSetupPage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaselineBloc, BaselineState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conscious header
              _ConsciousHeader(),

              const SizedBox(height: 24),

              // Baseline form
              _BaselineForm(state: state),

              const SizedBox(height: 24),

              // Summary card
              if (state.totalBaseline > 0) _SummaryCard(state: state),

              const SizedBox(height: 32),

              // Navigation buttons
              Row(
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
                      onPressed: state.isLoading || state.totalBaseline <= 0
                          ? null
                          : () {
                              context
                                  .read<BaselineBloc>()
                                  .add(const SaveBaselineEvent());
                              onContinue();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Lanjut ke Aset & Utang'),
                    ),
                  ),
                ],
              ),

              if (state.totalBaseline <= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Isi minimal satu kategori pengeluaran',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
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
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.receipt_long, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Berapa yang kamu butuhkan untuk bertahan hidup setiap bulan?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ini bukan tentang gaya hidup ideal.\n'
              'Ini tentang kebutuhan dasar yang tidak bisa ditawar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

/// Baseline form with all categories
class _BaselineForm extends StatefulWidget {
  final BaselineState state;

  const _BaselineForm({required this.state});

  @override
  State<_BaselineForm> createState() => _BaselineFormState();
}

class _BaselineFormState extends State<_BaselineForm> {
  late TextEditingController _housingController;
  late TextEditingController _foodController;
  late TextEditingController _transportController;
  late TextEditingController _healthController;
  late TextEditingController _utilitiesController;
  late TextEditingController _debtController;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _housingController = TextEditingController(
      text: widget.state.housing > 0 ? widget.state.housing.toString() : '',
    );
    _foodController = TextEditingController(
      text: widget.state.food > 0 ? widget.state.food.toString() : '',
    );
    _transportController = TextEditingController(
      text: widget.state.transport > 0 ? widget.state.transport.toString() : '',
    );
    _healthController = TextEditingController(
      text: widget.state.health > 0 ? widget.state.health.toString() : '',
    );
    _utilitiesController = TextEditingController(
      text: widget.state.utilities > 0 ? widget.state.utilities.toString() : '',
    );
    _debtController = TextEditingController(
      text: widget.state.debtPayments > 0 ? widget.state.debtPayments.toString() : '',
    );
    _otherController = TextEditingController(
      text: widget.state.other > 0 ? widget.state.other.toString() : '',
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran Bulanan Dasar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimasi rata-rata per bulan. Tidak harus persis.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),

            // Housing
            _BaselineField(
              icon: Icons.home,
              label: 'Tempat Tinggal',
              hint: 'Kontrakan, kost, cicilan rumah',
              controller: _housingController,
              onChanged: _updateBaseline,
            ),

            // Food
            _BaselineField(
              icon: Icons.restaurant,
              label: 'Makan & Minum',
              hint: 'Kebutuhan makan sehari-hari',
              controller: _foodController,
              onChanged: _updateBaseline,
            ),

            // Transport
            _BaselineField(
              icon: Icons.directions_car,
              label: 'Transportasi',
              hint: 'Bensin, ojol, transport umum',
              controller: _transportController,
              onChanged: _updateBaseline,
            ),

            // Utilities
            _BaselineField(
              icon: Icons.bolt,
              label: 'Utilitas',
              hint: 'Listrik, air, internet, pulsa',
              controller: _utilitiesController,
              onChanged: _updateBaseline,
            ),

            // Health
            _BaselineField(
              icon: Icons.medical_services,
              label: 'Kesehatan',
              hint: 'BPJS, obat rutin, asuransi',
              controller: _healthController,
              onChanged: _updateBaseline,
            ),

            // Debt payments
            _BaselineField(
              icon: Icons.credit_card,
              label: 'Cicilan Utang',
              hint: 'KTA, kartu kredit, pinjaman',
              controller: _debtController,
              onChanged: _updateBaseline,
            ),

            // Other
            _BaselineField(
              icon: Icons.more_horiz,
              label: 'Lainnya',
              hint: 'Kebutuhan wajib lainnya',
              controller: _otherController,
              onChanged: _updateBaseline,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single baseline field
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

/// Summary card showing total
class _SummaryCard extends StatelessWidget {
  final BaselineState state;

  const _SummaryCard({required this.state});

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Juta';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} Ribu';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Kebutuhan Bulananmu',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${_formatNumber(state.totalBaseline)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ini adalah "burn rate" bulananmu.\n'
              'Angka ini menentukan berapa lama uangmu bisa bertahan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade900,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
