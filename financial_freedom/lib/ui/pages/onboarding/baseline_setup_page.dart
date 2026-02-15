import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/ui/bloc/onboarding/baseline_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

/// Baseline Setup Page - Step 2 of Reality Entry
///
/// Format: Income Statement - EXPENSES / Pengeluaran
/// 16 kategori pengeluaran sesuai laporan keuangan
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
              // Header
              _ConsciousHeader(),

              const SizedBox(height: 24),

              // Expense form
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
              'EXPENSES / Pengeluaran Bulanan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Isi sesuai pengeluaran rata-rata per bulan.\n'
              'Kosongkan yang tidak berlaku.',
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

/// Baseline form with all 16 categories
class _BaselineForm extends StatefulWidget {
  final BaselineState state;

  const _BaselineForm({required this.state});

  @override
  State<_BaselineForm> createState() => _BaselineFormState();
}

class _BaselineFormState extends State<_BaselineForm> {
  late TextEditingController _rentController;
  late TextEditingController _householdController;
  late TextEditingController _transportController;
  late TextEditingController _insuranceController;
  late TextEditingController _incomeTaxController;
  late TextEditingController _propertyTaxController;
  late TextEditingController _personalPleasureController;
  late TextEditingController _familyRecreationController;
  late TextEditingController _giftsController;
  late TextEditingController _educationController;
  late TextEditingController _maintenanceController;
  late TextEditingController _householdStaffController;
  late TextEditingController _membershipController;
  late TextEditingController _healthcareController;
  late TextEditingController _socialContributionController;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _rentController = TextEditingController(
      text: widget.state.rent > 0 ? widget.state.rent.toString() : '',
    );
    _householdController = TextEditingController(
      text: widget.state.household > 0 ? widget.state.household.toString() : '',
    );
    _transportController = TextEditingController(
      text: widget.state.transportation > 0 ? widget.state.transportation.toString() : '',
    );
    _insuranceController = TextEditingController(
      text: widget.state.insurance > 0 ? widget.state.insurance.toString() : '',
    );
    _incomeTaxController = TextEditingController(
      text: widget.state.incomeTax > 0 ? widget.state.incomeTax.toString() : '',
    );
    _propertyTaxController = TextEditingController(
      text: widget.state.propertyTax > 0 ? widget.state.propertyTax.toString() : '',
    );
    _personalPleasureController = TextEditingController(
      text: widget.state.personalPleasure > 0 ? widget.state.personalPleasure.toString() : '',
    );
    _familyRecreationController = TextEditingController(
      text: widget.state.familyRecreation > 0 ? widget.state.familyRecreation.toString() : '',
    );
    _giftsController = TextEditingController(
      text: widget.state.gifts > 0 ? widget.state.gifts.toString() : '',
    );
    _educationController = TextEditingController(
      text: widget.state.education > 0 ? widget.state.education.toString() : '',
    );
    _maintenanceController = TextEditingController(
      text: widget.state.maintenance > 0 ? widget.state.maintenance.toString() : '',
    );
    _householdStaffController = TextEditingController(
      text: widget.state.householdStaff > 0 ? widget.state.householdStaff.toString() : '',
    );
    _membershipController = TextEditingController(
      text: widget.state.membership > 0 ? widget.state.membership.toString() : '',
    );
    _healthcareController = TextEditingController(
      text: widget.state.healthcare > 0 ? widget.state.healthcare.toString() : '',
    );
    _socialContributionController = TextEditingController(
      text: widget.state.socialContribution > 0 ? widget.state.socialContribution.toString() : '',
    );
    _otherController = TextEditingController(
      text: widget.state.other > 0 ? widget.state.other.toString() : '',
    );
  }

  @override
  void dispose() {
    _rentController.dispose();
    _householdController.dispose();
    _transportController.dispose();
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

  void _updateBaseline() {
    context.read<BaselineBloc>().add(
          UpdateBaselineEvent(
            rent: double.tryParse(_rentController.text) ?? 0,
            household: double.tryParse(_householdController.text) ?? 0,
            transportation: double.tryParse(_transportController.text) ?? 0,
            insurance: double.tryParse(_insuranceController.text) ?? 0,
            incomeTax: double.tryParse(_incomeTaxController.text) ?? 0,
            propertyTax: double.tryParse(_propertyTaxController.text) ?? 0,
            personalPleasure: double.tryParse(_personalPleasureController.text) ?? 0,
            familyRecreation: double.tryParse(_familyRecreationController.text) ?? 0,
            gifts: double.tryParse(_giftsController.text) ?? 0,
            education: double.tryParse(_educationController.text) ?? 0,
            maintenance: double.tryParse(_maintenanceController.text) ?? 0,
            householdStaff: double.tryParse(_householdStaffController.text) ?? 0,
            membership: double.tryParse(_membershipController.text) ?? 0,
            healthcare: double.tryParse(_healthcareController.text) ?? 0,
            socialContribution: double.tryParse(_socialContributionController.text) ?? 0,
            other: double.tryParse(_otherController.text) ?? 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Essential expenses
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran Wajib',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kebutuhan yang tidak bisa ditawar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                _BaselineField(
                  icon: Icons.home,
                  label: '1. Sewa / Angsuran',
                  hint: 'Rumah, property, kendaraan, gadget',
                  controller: _rentController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.kitchen,
                  label: '2. Biaya Rumah Tangga',
                  hint: 'Dapur, listrik, air, telepon, internet',
                  controller: _householdController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.directions_car,
                  label: '3. Biaya Transport',
                  hint: 'Bensin, maintenance, pajak kendaraan',
                  controller: _transportController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.shield,
                  label: '4. Asuransi',
                  hint: 'Property, kendaraan, kesehatan, jiwa',
                  controller: _insuranceController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.receipt,
                  label: '5. Pajak Penghasilan',
                  hint: 'PPh 21 / pajak pribadi',
                  controller: _incomeTaxController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.apartment,
                  label: '6. Pajak Property / Sewa',
                  hint: 'PBB, pajak sewa',
                  controller: _propertyTaxController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.medical_services,
                  label: '14. Kesehatan',
                  hint: 'Dokter, obat-obatan, BPJS',
                  controller: _healthcareController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.school,
                  label: '10. Pendidikan',
                  hint: 'Biaya sekolah anak, kursus pribadi',
                  controller: _educationController,
                  onChanged: _updateBaseline,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Optional expenses
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran Opsional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bisa dikurangi jika perlu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                _BaselineField(
                  icon: Icons.spa,
                  label: '7. Kesenangan Pribadi',
                  hint: 'Hobi, belanja pribadi',
                  controller: _personalPleasureController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.family_restroom,
                  label: '8. Rekreasi Keluarga',
                  hint: 'Liburan, jalan-jalan keluarga',
                  controller: _familyRecreationController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.card_giftcard,
                  label: '9. Hadiah',
                  hint: 'Hadiah untuk orang lain',
                  controller: _giftsController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.build,
                  label: '11. Perbaikan & Maintenance',
                  hint: 'Perbaikan rumah, servis aset',
                  controller: _maintenanceController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.people,
                  label: '12. Gaji Pegawai RT',
                  hint: 'Supir, baby sitter, pembantu',
                  controller: _householdStaffController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.card_membership,
                  label: '13. Keanggotaan Club',
                  hint: 'Gym, club, membership',
                  controller: _membershipController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.volunteer_activism,
                  label: '15. Kontribusi Sosial',
                  hint: 'Donasi, zakat, sumbangan',
                  controller: _socialContributionController,
                  onChanged: _updateBaseline,
                ),
                _BaselineField(
                  icon: Icons.more_horiz,
                  label: '16. Lainnya',
                  hint: 'Pengeluaran lain',
                  controller: _otherController,
                  onChanged: _updateBaseline,
                ),
              ],
            ),
          ),
        ),
      ],
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
              'Total Pengeluaran Bulanan',
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
