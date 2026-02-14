import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/ui/bloc/onboarding/time_freedom_bloc.dart';
import 'package:financial_freedom/ui/widgets/conscious_input.dart';

class ManageTimePage extends StatelessWidget {
  const ManageTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimeFreedomBloc>(
      create: (_) => getIt<TimeFreedomBloc>()..add(const LoadTimeProfileEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alokasi Waktu'),
          centerTitle: true,
        ),
        body: BlocConsumer<TimeFreedomBloc, TimeFreedomState>(
          listener: (context, state) {
            if (state is TimeFreedomReady && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          },
          builder: (context, state) {
            if (state is TimeFreedomLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TimeFreedomError) {
              return Center(child: Text(state.message));
            }

            double initWork = 0, initObligation = 0;

            if (state is TimeFreedomReady && state.profile != null) {
              initWork = state.profile!.workHoursPerWeek;
              initObligation = state.profile!.obligationHoursPerWeek;
            }

            return _TimeEditForm(
              initialWorkHours: initWork,
              initialObligationHours: initObligation,
            );
          },
        ),
      ),
    );
  }
}

class _TimeEditForm extends StatefulWidget {
  final double initialWorkHours;
  final double initialObligationHours;

  const _TimeEditForm({
    required this.initialWorkHours,
    required this.initialObligationHours,
  });

  @override
  State<_TimeEditForm> createState() => _TimeEditFormState();
}

class _TimeEditFormState extends State<_TimeEditForm> {
  late TextEditingController _workController;
  late TextEditingController _obligationController;

  @override
  void initState() {
    super.initState();
    _workController = TextEditingController(
      text: widget.initialWorkHours > 0 ? widget.initialWorkHours.toString() : '',
    );
    _obligationController = TextEditingController(
      text: widget.initialObligationHours > 0 ? widget.initialObligationHours.toString() : '',
    );
  }

  @override
  void dispose() {
    _workController.dispose();
    _obligationController.dispose();
    super.dispose();
  }

  double get _workHours => double.tryParse(_workController.text) ?? 0;
  double get _obligationHours => double.tryParse(_obligationController.text) ?? 0;
  double get _freeHours {
    final free = 168 - 56 - _workHours - _obligationHours;
    return free > 0 ? free : 0;
  }

  bool get _isValid => _workHours > 0 && (_workHours + _obligationHours + 56) <= 168;

  void _updateTime() {
    setState(() {});
    context.read<TimeFreedomBloc>().add(
          UpdateTimeAllocationEvent(
            workHours: _workHours,
            obligationHours: _obligationHours,
          ),
        );
  }

  void _save() {
    _updateTime();
    context.read<TimeFreedomBloc>().add(const SaveTimeProfileEvent());
  }

  Color _getInsightColor() {
    final freePercent = _freeHours / 168;
    if (freePercent >= 0.4) return Colors.green;
    if (freePercent >= 0.25) return Colors.amber;
    if (freePercent >= 0.15) return Colors.orange;
    return Colors.red;
  }

  String _getInsightMessage() {
    final freePercent = _freeHours / 168;
    if (freePercent >= 0.4) {
      return 'Kamu memiliki keseimbangan waktu yang baik!';
    } else if (freePercent >= 0.25) {
      return 'Waktu bebasmu lumayan, tapi masih bisa ditingkatkan.';
    } else if (freePercent >= 0.15) {
      return 'Waktu bebasmu terbatas. Pikirkan cara membeli kembali waktumu.';
    } else {
      return 'Hampir seluruh waktumu habis untuk kerja dan kewajiban. Ini tanda peringatan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workPercent = (_workHours / 168 * 100).round();
    final obligationPercent = (_obligationHours / 168 * 100).round();
    final freePercent = (_freeHours / 168 * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.access_time, size: 40, color: Colors.teal),
                  const SizedBox(height: 12),
                  Text(
                    'Alokasi Waktu Mingguan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dalam seminggu kamu punya 168 jam.\nKe mana saja waktu itu pergi?',
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

                  // Free time display
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
                                '${_freeHours.toStringAsFixed(1)} jam',
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
          ),

          const SizedBox(height: 16),

          // Visualization
          if (_isValid) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visualisasi Waktu',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
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
                                  ? Text('$workPercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
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
                                  ? Text('$obligationPercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
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
                                  ? Text('$freePercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
            ),

            const SizedBox(height: 16),

            // Insight
            Card(
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
                          'Indeks Kebebasan Waktu: ${(_freeHours / 168 * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getInsightColor(),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_getInsightMessage(), style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _isValid ? _save : null,
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
