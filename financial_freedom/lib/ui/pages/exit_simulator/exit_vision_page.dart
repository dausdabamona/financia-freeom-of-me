import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/ui/bloc/exit_simulator/exit_simulator.dart';
import 'package:financial_freedom/ui/pages/exit_simulator/weekly_timeline_page.dart';
import 'package:financial_freedom/ui/pages/exit_simulator/reflection_page.dart';

/// Exit Vision Page - Entry point for the Exit Simulator
///
/// Philosophy: "Mari kita lihat masa depanmu jika gaji berhenti hari ini.
/// Bukan untuk menakuti, tapi untuk memberi arah."
class ExitVisionPage extends StatelessWidget {
  const ExitVisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExitSimulatorBloc>(
      create: (context) => getIt<ExitSimulatorBloc>()
        ..add(const InitializeSimulatorEvent()),
      child: const _ExitVisionView(),
    );
  }
}

class _ExitVisionView extends StatelessWidget {
  const _ExitVisionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exit Simulator'),
        centerTitle: true,
      ),
      body: BlocBuilder<ExitSimulatorBloc, ExitSimulatorState>(
        builder: (context, state) {
          if (state is ExitSimulatorInitial || state is ExitSimulatorLoading) {
            return const _LoadingView();
          }

          if (state is ExitSimulatorReady) {
            return _WelcomeView(
              hasExistingSimulation: state.hasExistingSimulation,
            );
          }

          if (state is ExitSimulatorRunning) {
            return const _SimulatingView();
          }

          if (state is ExitSimulatorEmpty) {
            return _EmptyView(message: state.message);
          }

          if (state is ExitSimulatorLoaded) {
            return _LoadedView(state: state);
          }

          if (state is ExitSimulatorError) {
            return _ErrorView(message: state.message);
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
      child: CircularProgressIndicator(),
    );
  }
}

/// Welcome view - invitation to start simulation
class _WelcomeView extends StatelessWidget {
  final bool hasExistingSimulation;

  const _WelcomeView({required this.hasExistingSimulation});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore,
              size: 64,
              color: Colors.teal.shade700,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'Exit Simulator',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Philosophy message
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.format_quote, color: Colors.teal),
                  const SizedBox(height: 12),
                  Text(
                    '"Mari kita lihat masa depanmu\njika gaji berhenti hari ini.\n\n'
                    'Bukan untuk menakuti,\ntapi untuk memberi arah."',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // What you'll see
          Text(
            'Dalam simulasi ini, kamu akan melihat:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.timeline,
            text: 'Proyeksi minggu per minggu hingga 3 tahun',
          ),
          _FeatureItem(
            icon: Icons.warning_amber,
            text: 'Titik-titik rawan yang perlu diwaspadai',
          ),
          _FeatureItem(
            icon: Icons.compare_arrows,
            text: 'Bagaimana perubahan kecil berdampak besar',
          ),
          _FeatureItem(
            icon: Icons.lightbulb,
            text: 'Insight dan langkah yang bisa diambil',
          ),

          const SizedBox(height: 48),

          // Start button
          ElevatedButton(
            onPressed: () {
              context.read<ExitSimulatorBloc>().add(const RunSimulationEvent());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.teal,
            ),
            child: Text(
              hasExistingSimulation ? 'Perbarui Simulasi' : 'Mulai Simulasi',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy note
          Text(
            'Semua perhitungan dilakukan lokal di perangkatmu.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Simulating view
class _SimulatingView extends StatelessWidget {
  const _SimulatingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Menghitung proyeksi masa depanmu...',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Memproses 156 minggu untuk beberapa skenario.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view - no financial data
class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loaded view - show results
class _LoadedView extends StatefulWidget {
  final ExitSimulatorLoaded state;

  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageDot(isActive: _currentPage == 0, label: 'Timeline'),
              const SizedBox(width: 8),
              _PageDot(isActive: _currentPage == 1, label: 'Skenario'),
              const SizedBox(width: 8),
              _PageDot(isActive: _currentPage == 2, label: 'Refleksi'),
            ],
          ),
        ),

        // Page content
        Expanded(
          child: PageView(
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            children: [
              WeeklyTimelineView(state: widget.state),
              _ScenarioComparisonView(state: widget.state),
              ReflectionView(state: widget.state),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;
  final String label;

  const _PageDot({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.teal : Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Scenario comparison view
class _ScenarioComparisonView extends StatelessWidget {
  final ExitSimulatorLoaded state;

  const _ScenarioComparisonView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bagaimana Jika...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat bagaimana perubahan kecil berdampak pada runwaymu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),

          // Scenario cards
          ...state.results.map((result) => _ScenarioCard(
                result: result,
                isSelected: result.scenario.id == state.selectedResult.scenario.id,
                baselineWeeksSafe: state.baselineResult.insight.weeksSafe,
              )),

          // Best comparison insight
          if (state.bestComparison != null &&
              state.bestComparison!.isAlternativeBetter) ...[
            const SizedBox(height: 24),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Insight',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.bestComparison!.comparisonMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final dynamic result;
  final bool isSelected;
  final int baselineWeeksSafe;

  const _ScenarioCard({
    required this.result,
    required this.isSelected,
    required this.baselineWeeksSafe,
  });

  @override
  Widget build(BuildContext context) {
    final scenario = result.scenario;
    final insight = result.insight;
    final weeksDiff = insight.weeksSafe - baselineWeeksSafe;

    return Card(
      color: isSelected ? scenario.color.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          context.read<ExitSimulatorBloc>().add(
                SelectScenarioEvent(scenarioId: scenario.id),
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(scenario.icon, color: scenario.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          scenario.impactDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!scenario.isBaseline && weeksDiff != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: weeksDiff > 0
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${weeksDiff > 0 ? '+' : ''}$weeksDiff minggu',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: weeksDiff > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricChip(
                    label: 'Aman',
                    value: '${insight.weeksSafe} minggu',
                    color: Colors.green,
                  ),
                  _MetricChip(
                    label: 'Kritis',
                    value: 'Minggu ${insight.weeksToCritical}',
                    color: Colors.orange,
                  ),
                  _MetricChip(
                    label: 'Runway',
                    value: insight.runwayFormatted,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Oops! Ada masalah',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context
                    .read<ExitSimulatorBloc>()
                    .add(const InitializeSimulatorEvent());
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
