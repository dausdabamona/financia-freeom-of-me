import 'package:flutter/material.dart';
import 'package:financial_freedom/ui/bloc/exit_simulator/exit_simulator.dart';

/// Reflection View - Final page with insights and wisdom
///
/// Philosophy: This is not about fear. This is about direction.
///
/// Tone:
/// - Visioner (menunjukkan arah besar)
/// - Menenangkan (tidak memicu panik)
/// - Jujur (tidak menyembunyikan realita)
class ReflectionView extends StatelessWidget {
  final ExitSimulatorLoaded state;

  const ReflectionView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final insight = state.selectedResult.insight;
    final bestComparison = state.bestComparison;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main reflection card
          _ReflectionCard(
            title: 'Realitamu',
            message: insight.emotionalMessage,
            icon: Icons.visibility,
            color: Colors.blue,
          ),

          const SizedBox(height: 16),

          // Visionary message
          _ReflectionCard(
            title: 'Arah Besar',
            message: insight.visionaryMessage,
            icon: Icons.explore,
            color: Colors.teal,
          ),

          const SizedBox(height: 16),

          // Calming message
          _ReflectionCard(
            title: 'Perspektif',
            message: insight.calmingMessage,
            icon: Icons.self_improvement,
            color: Colors.purple,
          ),

          const SizedBox(height: 16),

          // Realistic truth
          _ReflectionCard(
            title: 'Kebenaran',
            message: insight.realisticMessage,
            icon: Icons.fact_check,
            color: Colors.orange,
          ),

          // Comparison insight if available
          if (bestComparison != null && bestComparison.isAlternativeBetter) ...[
            const SizedBox(height: 24),
            _ActionInsightCard(comparison: bestComparison),
          ],

          const SizedBox(height: 32),

          // Wisdom quote
          _WisdomCard(),

          const SizedBox(height: 24),

          // Next steps
          _NextStepsCard(insight: insight),
        ],
      ),
    );
  }
}

/// Single reflection card
class _ReflectionCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _ReflectionCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action insight card based on comparison
class _ActionInsightCard extends StatelessWidget {
  final SimulationComparison comparison;

  const _ActionInsightCard({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final weeksDiff = comparison.runwayDifference;
    final scenarioName = comparison.alternative.scenario.name;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.lightbulb, color: Colors.green, size: 32),
            const SizedBox(height: 12),
            Text(
              'Satu Langkah Kecil',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dengan "$scenarioName", kamu bisa menambah '
              '$weeksDiff minggu ke runway-mu.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              comparison.comparisonMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
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

/// Wisdom quote card
class _WisdomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.format_quote, color: Colors.amber, size: 32),
            const SizedBox(height: 16),
            Text(
              '"Kamu belum sepenuhnya merdeka,\n'
              'tapi kamu sedang membangun jarak aman yang nyata.\n\n'
              'Setiap minggu yang kamu menambah runway,\n'
              'kamu sedang membeli kembali waktumu."',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Next steps card
class _NextStepsCard extends StatelessWidget {
  final dynamic insight;

  const _NextStepsCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final steps = _getRecommendedSteps();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_walk, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Text(
                  'Langkah Selanjutnya',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            ...steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(step)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendedSteps() {
    final weeksSafe = insight.weeksSafe as int;

    if (weeksSafe < 4) {
      return [
        'Identifikasi satu pengeluaran yang bisa dikurangi minggu ini',
        'Cari satu sumber income tambahan yang bisa dimulai segera',
        'Pastikan tidak ada kebocoran uang yang tidak disadari',
      ];
    }

    if (weeksSafe < 12) {
      return [
        'Fokus menambah buffer 1-2 bulan lagi',
        'Review pengeluaran non-esensial',
        'Mulai riset side income yang sesuai skill-mu',
      ];
    }

    if (weeksSafe < 26) {
      return [
        'Pertahankan momentum yang sudah ada',
        'Mulai pikirkan investasi untuk passive income',
        'Dokumentasikan pengeluaran untuk optimasi lebih lanjut',
      ];
    }

    return [
      'Kamu sudah dalam posisi yang baik—pertahankan',
      'Fokus pada membangun passive income',
      'Mulai pikirkan apa yang ingin kamu lakukan dengan waktu bebasmu',
    ];
  }
}
