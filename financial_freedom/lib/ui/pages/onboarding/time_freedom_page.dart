import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/ui/bloc/onboarding/time_freedom_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

/// Time Freedom Page - Step 4 of Reality Entry
///
/// UX Philosophy: Understanding where your time goes
/// "Berapa banyak waktumu yang benar-benar milikmu?"
class TimeFreedomPage extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const TimeFreedomPage({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeFreedomBloc, TimeFreedomState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conscious header
              _ConsciousHeader(),

              const SizedBox(height: 24),

              // Time allocation form
              _TimeAllocationForm(state: state),

              const SizedBox(height: 24),

              // Time visualization
              if (state.isValid) _TimeVisualization(state: state),

              const SizedBox(height: 24),

              // Freedom insight
              if (state.isValid) _FreedomInsight(state: state),

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
                      onPressed: state.isLoading || !state.isValid
                          ? null
                          : () {
                              context
                                  .read<TimeFreedomBloc>()
                                  .add(const SaveTimeProfileEvent());
                              onComplete();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Selesai - Lihat Realita',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              if (!state.isValid)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.totalHours > 168
                        ? 'Total jam melebihi 168 jam/minggu'
                        : 'Isi minimal jam kerja',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
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
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.access_time, size: 48, color: Colors.teal),
            const SizedBox(height: 16),
            Text(
              'Berapa banyak waktumu yang benar-benar milikmu?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kebebasan finansial bukan hanya tentang uang.\n'
              'Tapi tentang memiliki waktumu sendiri.',
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

/// Time allocation form
class _TimeAllocationForm extends StatefulWidget {
  final TimeFreedomState state;

  const _TimeAllocationForm({required this.state});

  @override
  State<_TimeAllocationForm> createState() => _TimeAllocationFormState();
}

class _TimeAllocationFormState extends State<_TimeAllocationForm> {
  late TextEditingController _workController;
  late TextEditingController _obligationController;

  @override
  void initState() {
    super.initState();
    _workController = TextEditingController(
      text: widget.state.workHours > 0 ? widget.state.workHours.toString() : '',
    );
    _obligationController = TextEditingController(
      text: widget.state.obligationHours > 0
          ? widget.state.obligationHours.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _workController.dispose();
    _obligationController.dispose();
    super.dispose();
  }

  void _updateTime() {
    context.read<TimeFreedomBloc>().add(
          UpdateTimeAllocationEvent(
            workHours: double.tryParse(_workController.text) ?? 0,
            obligationHours: double.tryParse(_obligationController.text) ?? 0,
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
              'Alokasi Waktu Mingguan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dalam seminggu kamu punya 168 jam.\nKe mana saja waktu itu pergi?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),

            // Work hours
            Row(
              children: [
                const Icon(Icons.work, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: HoursInputField(
                    label: 'Jam Kerja per Minggu',
                    hint: '40',
                    helperText: 'Termasuk perjalanan dan lembur',
                    controller: _workController,
                    onChanged: (_) => _updateTime(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Obligation hours
            Row(
              children: [
                const Icon(Icons.home_work, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: HoursInputField(
                    label: 'Jam Kewajiban Lain per Minggu',
                    hint: '20',
                    helperText: 'Tidur 56 jam (8jam/hari) + makan, mandi, dll',
                    controller: _obligationController,
                    onChanged: (_) => _updateTime(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Calculated free time
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.free_breakfast, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Waktu Bebas per Minggu'),
                        Text(
                          '${widget.state.freeHours.toStringAsFixed(1)} jam',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Time visualization pie chart (simple)
class _TimeVisualization extends StatelessWidget {
  final TimeFreedomState state;

  const _TimeVisualization({required this.state});

  @override
  Widget build(BuildContext context) {
    final workPercent = (state.workHours / 168 * 100).round();
    final obligationPercent = (state.obligationHours / 168 * 100).round();
    final freePercent = (state.freeHours / 168 * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visualisasi Waktu Mingguan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Simple bar representation
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: workPercent.clamp(1, 100),
                    child: Container(
                      height: 32,
                      color: Colors.orange,
                      alignment: Alignment.center,
                      child: workPercent >= 15
                          ? Text(
                              '$workPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: obligationPercent.clamp(1, 100),
                    child: Container(
                      height: 32,
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: obligationPercent >= 15
                          ? Text(
                              '$obligationPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: freePercent.clamp(1, 100),
                    child: Container(
                      height: 32,
                      color: Colors.green,
                      alignment: Alignment.center,
                      child: freePercent >= 10
                          ? Text(
                              '$freePercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: Colors.orange, label: 'Kerja'),
                _LegendItem(color: Colors.blue, label: 'Kewajiban'),
                _LegendItem(color: Colors.green, label: 'Bebas'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Freedom insight
class _FreedomInsight extends StatelessWidget {
  final TimeFreedomState state;

  const _FreedomInsight({required this.state});

  String _getInsightMessage() {
    final freePercent = state.freeHours / 168;

    if (freePercent >= 0.4) {
      return 'Kamu memiliki keseimbangan waktu yang baik! '
          'Waktu bebas yang cukup untuk menikmati hidup.';
    } else if (freePercent >= 0.25) {
      return 'Waktu bebasmu lumayan, tapi masih bisa ditingkatkan. '
          'Pikirkan bagaimana cara mengurangi jam kerja tanpa mengurangi penghasilan.';
    } else if (freePercent >= 0.15) {
      return 'Waktu bebasmu terbatas. Kamu bekerja keras, tapi apakah sepadan? '
          'Ini saatnya memikirkan strategi untuk membeli kembali waktumu.';
    } else {
      return 'Hampir seluruh waktumu habis untuk kerja dan kewajiban. '
          'Ini adalah tanda peringatan. Kebebasan finansial bukan hanya tentang uang, '
          'tapi juga tentang memiliki waktu untuk hidup.';
    }
  }

  Color _getInsightColor() {
    final freePercent = state.freeHours / 168;

    if (freePercent >= 0.4) return Colors.green;
    if (freePercent >= 0.25) return Colors.amber;
    if (freePercent >= 0.15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getInsightColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: _getInsightColor()),
                const SizedBox(width: 8),
                Text(
                  'Indeks Kebebasan Waktu: ${(state.timeFreedomIndex * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getInsightColor(),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getInsightMessage(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
