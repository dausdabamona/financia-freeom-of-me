import 'package:flutter/material.dart';
import 'package:financial_freedom/ui/pages/manage/manage_accounts_page.dart';
import 'package:financial_freedom/ui/pages/manage/manage_baseline_page.dart';
import 'package:financial_freedom/ui/pages/manage/manage_assets_page.dart';
import 'package:financial_freedom/ui/pages/manage/manage_liabilities_page.dart';
import 'package:financial_freedom/ui/pages/manage/manage_time_page.dart';

class ManageHubPage extends StatelessWidget {
  const ManageHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.edit_note, size: 40, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'Perbarui Realitamu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data keuangan berubah seiring waktu.\n'
                    'Perbarui secara berkala untuk kompas yang akurat.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section cards
          _ManageSectionCard(
            icon: Icons.account_balance_wallet,
            title: 'Akun Keuangan',
            subtitle: 'Bank, e-wallet, tunai, investasi',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageAccountsPage()),
            ),
          ),

          _ManageSectionCard(
            icon: Icons.receipt_long,
            title: 'Pengeluaran Bulanan',
            subtitle: 'Kebutuhan dasar per bulan',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageBaselinePage()),
            ),
          ),

          _ManageSectionCard(
            icon: Icons.trending_up,
            title: 'Aset',
            subtitle: 'Properti, kendaraan, investasi, tabungan',
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageAssetsPage()),
            ),
          ),

          _ManageSectionCard(
            icon: Icons.trending_down,
            title: 'Utang',
            subtitle: 'KPR, pinjaman, kartu kredit',
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageLiabilitiesPage()),
            ),
          ),

          _ManageSectionCard(
            icon: Icons.access_time,
            title: 'Alokasi Waktu',
            subtitle: 'Jam kerja dan waktu bebas',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageTimePage()),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ManageSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManageSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
