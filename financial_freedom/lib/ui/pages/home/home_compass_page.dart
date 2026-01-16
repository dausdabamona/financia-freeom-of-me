import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';
import 'package:financial_freedom/domain/entities/freedom_phase.dart';
import 'package:financial_freedom/ui/bloc/compass/compass.dart';

/// Home Compass Page - Main screen of the Financial Freedom app
///
/// Shows:
/// - Current freedom phase
/// - Key metrics (runway, salary dependency)
/// - Today's "Langkah Kecil" compass guidance
///
/// Tone: Akrab, Jujur, Navigator tegas + sahabat + mentor
class HomeCompassPage extends StatelessWidget {
  const HomeCompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Freedom'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CompassBloc>().add(const RefreshCompassEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<CompassBloc, CompassState>(
        builder: (context, state) {
          if (state is CompassInitial || state is CompassLoading) {
            return const _LoadingView();
          }

          if (state is CompassError) {
            return _ErrorView(message: state.message);
          }

          if (state is CompassEmpty) {
            return _EmptyView(message: state.message);
          }

          if (state is CompassLoaded) {
            return _LoadedView(
              snapshot: state.snapshot,
              compass: state.compass,
              isFirstTimeUser: state.isFirstTimeUser,
            );
          }

          return const _LoadingView();
        },
      ),
    );
  }
}

/// Loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Membaca realita keuanganmu...'),
        ],
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Ada masalah',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<CompassBloc>().add(const LoadCompassEvent());
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view for first-time users
class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Selamat Datang, Navigator!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            const Text(
              'Perjalanan menuju kebebasan finansial dimulai dari mengenal realita.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loaded view with snapshot and compass data
class _LoadedView extends StatelessWidget {
  final FinancialSnapshot snapshot;
  final DailyCompassEntry compass;
  final bool isFirstTimeUser;

  const _LoadedView({
    required this.snapshot,
    required this.compass,
    required this.isFirstTimeUser,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CompassBloc>().add(const RefreshCompassEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Freedom Phase Card
            _FreedomPhaseCard(phase: snapshot.freedomPhase),

            const SizedBox(height: 16),

            // Key Metrics
            _MetricsCard(snapshot: snapshot),

            const SizedBox(height: 16),

            // Situation Message
            _SituationCard(message: snapshot.situationMessage),

            const SizedBox(height: 24),

            // Daily Compass
            _CompassCard(compass: compass),

            if (isFirstTimeUser) ...[
              const SizedBox(height: 24),
              _FirstTimeUserNote(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Freedom Phase Card
class _FreedomPhaseCard extends StatelessWidget {
  final FreedomPhase phase;

  const _FreedomPhaseCard({required this.phase});

  Color _getPhaseColor() {
    switch (phase) {
      case FreedomPhase.bound:
        return Colors.red;
      case FreedomPhase.transition:
        return Colors.orange;
      case FreedomPhase.independent:
        return Colors.amber;
      case FreedomPhase.optional:
        return Colors.lightGreen;
      case FreedomPhase.free:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getPhaseColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.explore,
              size: 48,
              color: _getPhaseColor(),
            ),
            const SizedBox(height: 12),
            Text(
              'Fase: ${phase.nameId}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _getPhaseColor(),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              phase.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Metrics Card
class _MetricsCard extends StatelessWidget {
  final FinancialSnapshot snapshot;

  const _MetricsCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Realita Keuanganmu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _MetricRow(
              icon: Icons.timer,
              label: 'Runway',
              value: snapshot.runwayFormatted,
              color: snapshot.isInWarningZone ? Colors.orange : Colors.green,
            ),
            _MetricRow(
              icon: Icons.work,
              label: 'Ketergantungan Gaji',
              value: '${snapshot.salaryDependencyPercent.toStringAsFixed(0)}%',
              color: snapshot.salaryDependencyRatio > 0.7
                  ? Colors.red
                  : Colors.blue,
            ),
            _MetricRow(
              icon: Icons.savings,
              label: 'Passive Income',
              value: 'Rp ${_formatNumber(snapshot.totalPassiveIncome)}/bln',
              color: Colors.green,
            ),
            _MetricRow(
              icon: Icons.trending_up,
              label: 'Net Worth',
              value: 'Rp ${_formatNumber(snapshot.netWorth)}',
              color: snapshot.netWorth >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}Rb';
    }
    return value.toStringAsFixed(0);
  }
}

/// Single metric row
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Situation Card
class _SituationCard extends StatelessWidget {
  final String message;

  const _SituationCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade900,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily Compass Card - "Langkah Kecil Hari Ini"
class _CompassCard extends StatelessWidget {
  final DailyCompassEntry compass;

  const _CompassCard({required this.compass});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: compass.completed ? Colors.green.shade50 : Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  compass.focusDomain.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Langkah Kecil Hari Ini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (compass.completed)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fokus: ${compass.focusDomain.nameId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const Divider(),
            Text(
              compass.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            if (!compass.completed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<CompassBloc>()
                        .add(const MarkCompassCompletedEvent());
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Sudah Dilakukan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// First time user note
class _FirstTimeUserNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Tips untuk Memulai',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1. Tambahkan akun-akun keuanganmu (bank, e-wallet, tunai)\n'
              '2. Catat pengeluaran bulanan baseline-mu\n'
              '3. Tambahkan aset dan utang jika ada\n'
              '4. Refresh untuk melihat realita keuanganmu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
