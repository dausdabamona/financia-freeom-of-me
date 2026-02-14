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
  final _rentController = TextEditingController();
  final _householdController = TextEditingController();
  final _transportationController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _incomeTaxController = TextEditingController();
  final _propertyTaxController = TextEditingController();
  final _personalPleasureController = TextEditingController();
  final _familyRecreationController = TextEditingController();
  final _giftsController = TextEditingController();
  final _educationController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _householdStaffController = TextEditingController();
  final _membershipController = TextEditingController();
  final _healthcareController = TextEditingController();
  final _socialContributionController = TextEditingController();
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _rentController.dispose();
    _householdController.dispose();
    _transportationController.dispose();
    _insuranceController.dispose();
    _incomeTaxController.dispose();
    _propertyTaxController.dispose();
    _personalPleasureController.dispose();
    _familyRecreationController.dispose();
    _giftsController.dispose();
    _educationController.dispose();
    _maintenanceController.dispose();
    _householdStaffController.dispose();
    _membershipController.dispose();
    _healthcareController.dispose();
    _socialContributionController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  double _val(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void _updateBaseline() {
    context.read<BaselineBloc>().add(
          UpdateBaselineEvent(
            rent: _val(_rentController),
            household: _val(_householdController),
            transportation: _val(_transportationController),
            insurance: _val(_insuranceController),
            incomeTax: _val(_incomeTaxController),
            propertyTax: _val(_propertyTaxController),
            personalPleasure: _val(_personalPleasureController),
            familyRecreation: _val(_familyRecreationController),
            gifts: _val(_giftsController),
            education: _val(_educationController),
            maintenance: _val(_maintenanceController),
            householdStaff: _val(_householdStaffController),
            membership: _val(_membershipController),
            healthcare: _val(_healthcareController),
            socialContribution: _val(_socialContributionController),
            other: _val(_otherController),
          ),
        );
  }

  double get _totalBaseline {
    return _val(_rentController) +
        _val(_householdController) +
        _val(_transportationController) +
        _val(_insuranceController) +
        _val(_incomeTaxController) +
        _val(_propertyTaxController) +
        _val(_personalPleasureController) +
        _val(_familyRecreationController) +
        _val(_giftsController) +
        _val(_educationController) +
        _val(_maintenanceController) +
        _val(_householdStaffController) +
        _val(_membershipController) +
        _val(_healthcareController) +
        _val(_socialContributionController) +
        _val(_otherController);
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
                  _BaselineField(icon: Icons.home, label: 'Sewa / Angsuran', hint: 'Kontrakan, kost, cicilan rumah', controller: _rentController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.kitchen, label: 'Biaya Rumah Tangga', hint: 'Kebutuhan rumah tangga sehari-hari', controller: _householdController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.directions_car, label: 'Biaya Transport', hint: 'Bensin, ojol, transport umum', controller: _transportationController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.shield, label: 'Asuransi', hint: 'Asuransi jiwa, kesehatan, kendaraan', controller: _insuranceController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.account_balance, label: 'Pajak Penghasilan', hint: 'PPh 21, pajak tahunan', controller: _incomeTaxController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.apartment, label: 'Pajak Property', hint: 'PBB, pajak tanah', controller: _propertyTaxController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.celebration, label: 'Kesenangan Pribadi', hint: 'Hobi, hiburan pribadi', controller: _personalPleasureController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.family_restroom, label: 'Rekreasi Keluarga', hint: 'Liburan, jalan-jalan keluarga', controller: _familyRecreationController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.card_giftcard, label: 'Hadiah', hint: 'Kado, sumbangan acara', controller: _giftsController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.school, label: 'Pendidikan', hint: 'SPP, kursus, buku', controller: _educationController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.build, label: 'Perbaikan & Maintenance', hint: 'Servis rumah, kendaraan', controller: _maintenanceController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.people, label: 'Gaji Pegawai RT', hint: 'ART, supir, tukang kebun', controller: _householdStaffController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.card_membership, label: 'Keanggotaan Club', hint: 'Gym, club, membership', controller: _membershipController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.medical_services, label: 'Kesehatan', hint: 'BPJS, obat rutin, dokter', controller: _healthcareController, onChanged: _updateBaseline),
                  _BaselineField(icon: Icons.volunteer_activism, label: 'Kontribusi Sosial', hint: 'Zakat, sedekah, donasi', controller: _socialContributionController, onChanged: _updateBaseline),
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
