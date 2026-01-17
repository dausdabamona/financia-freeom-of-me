import 'package:flutter/material.dart';

/// Halaman pemilihan mode aplikasi
///
/// Memungkinkan pengguna memilih antara:
/// - Financial Freedom (Kompas Keuangan Pribadi)
/// - PPK Assistant (Manajemen UP/TUP)
class AppModeSelectorPage extends StatelessWidget {
  const AppModeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pilih Mode Aplikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aplikasi ini memiliki dua mode yang dapat Anda gunakan',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _ModeCard(
                icon: Icons.explore,
                title: 'Financial Freedom',
                subtitle: 'Kompas Kebebasan Finansial Pribadi',
                description:
                    'Lacak perjalanan keuangan pribadi Anda menuju kebebasan finansial',
                color: Colors.green,
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.account_balance,
                title: 'Asisten PPK',
                subtitle: 'Manajemen UP/TUP - Permen KP 56/2024',
                description:
                    'Kelola pengajuan Uang Persediaan dan Tambahan UP sesuai regulasi',
                color: Colors.blue,
                onTap: () => Navigator.pushReplacementNamed(context, '/ppk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
