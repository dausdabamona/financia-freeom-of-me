import 'package:flutter/material.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/usecases/generate_daily_snapshot.dart';
import 'package:financial_freedom/ui/pages/onboarding/onboarding_flow_page.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onResetComplete;

  const SettingsPage({super.key, this.onResetComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App info card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore, size: 48, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Financial Freedom',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kompas Kebebasan Finansialmu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versi 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Data section
          Text(
            'Data',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.green),
                  title: const Text('Perbarui Kompas'),
                  subtitle: const Text('Hitung ulang realita keuanganmu'),
                  onTap: () => _refreshCompass(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.replay, color: Colors.blue),
                  title: const Text('Ulangi Onboarding'),
                  subtitle: const Text('Mulai setup dari awal'),
                  onTap: () => _rerunOnboarding(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger zone
          Text(
            'Zona Berbahaya',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Hapus Semua Data',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('Menghapus semua data keuangan secara permanen'),
              onTap: () => _showResetConfirmation(context),
            ),
          ),

          const SizedBox(height: 24),

          // Philosophy section
          Text(
            'Filosofi',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),

          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.format_quote, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    '"Kebebasan finansial bukan tentang jadi kaya.\n'
                    'Tapi tentang memiliki waktumu sendiri."',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privasi',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semua data tersimpan lokal di perangkatmu.\n'
                          'Tidak ada cloud, tidak ada iklan, tidak ada tracking.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _refreshCompass(BuildContext context) async {
    try {
      final generateSnapshot = getIt<GenerateDailySnapshotUseCase>();
      await generateSnapshot.call(const NoParams());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kompas berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui: $e')),
        );
      }
    }
  }

  void _rerunOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingFlowPage(),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yakin ingin menghapus semua data?'),
        content: const Text(
          'Tindakan ini tidak bisa dibatalkan.\n\n'
          'Semua data keuangan, aset, utang, dan riwayat akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetAllData(context);
            },
            child: const Text('Hapus Semua Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData(BuildContext context) async {
    try {
      final db = getIt<AppDatabase>();
      await db.deleteAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data berhasil dihapus')),
        );
        onResetComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    }
  }
}

