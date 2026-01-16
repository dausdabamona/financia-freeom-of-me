import 'package:flutter/material.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';
import 'package:financial_freedom/domain/entities/weekly_projection.dart';
import 'package:financial_freedom/ui/bloc/exit_simulator/exit_simulator.dart';

/// Weekly Timeline View - Shows week-by-week projection
///
/// Displays a scrollable timeline with color-coded zones
class WeeklyTimelineView extends StatelessWidget {
  final ExitSimulatorLoaded state;

  const WeeklyTimelineView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final projections = state.selectedResult.weeklyProjections;
    final insight = state.selectedResult.insight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _TimelineHeader(insight: insight),

          const SizedBox(height: 16),

          // Zone legend
          _ZoneLegend(),

          const SizedBox(height: 16),

          // Visual timeline bar
          _TimelineBar(projections: projections),

          const SizedBox(height: 24),

          // Key milestones
          _KeyMilestones(result: state.selectedResult),

          const SizedBox(height: 24),

          // Detailed week list (first 52 weeks)
          _WeeklyList(
            projections: projections.take(52).toList(),
          ),

          if (projections.length > 52) ...[
            const SizedBox(height: 16),
            Text(
              'Menampilkan 52 minggu pertama dari ${projections.length} minggu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Timeline header with key info
class _TimelineHeader extends StatelessWidget {
  final dynamic insight;

  const _TimelineHeader({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: insight.currentZone.color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  insight.currentZone.icon,
                  color: insight.currentZone.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zona Saat Ini: ${insight.currentZone.nameId}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: insight.currentZone.color,
                        ),
                      ),
                      Text(
                        'Runway: ${insight.runwayFormatted}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderMetric(
                  label: 'Minggu Aman',
                  value: '${insight.weeksSafe}',
                  color: Colors.green,
                ),
                _HeaderMetric(
                  label: 'Mulai Waspada',
                  value: 'Mg ${insight.weeksSafe + 1}',
                  color: Colors.orange,
                ),
                _HeaderMetric(
                  label: 'Zona Kritis',
                  value: 'Mg ${insight.weeksToCritical}',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Zone legend
class _ZoneLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ExitZone.values.map((zone) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: zone.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              zone.nameId,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Visual timeline bar showing zones over time
class _TimelineBar extends StatelessWidget {
  final List<WeeklyProjection> projections;

  const _TimelineBar({required this.projections});

  @override
  Widget build(BuildContext context) {
    // Group consecutive weeks by zone
    final segments = <_TimelineSegment>[];
    ExitZone? currentZone;
    int segmentStart = 1;

    for (int i = 0; i < projections.length; i++) {
      final week = projections[i];
      if (currentZone != week.zone) {
        if (currentZone != null) {
          segments.add(_TimelineSegment(
            zone: currentZone,
            startWeek: segmentStart,
            endWeek: i,
          ));
        }
        currentZone = week.zone;
        segmentStart = i + 1;
      }
    }

    // Add final segment
    if (currentZone != null) {
      segments.add(_TimelineSegment(
        zone: currentZone,
        startWeek: segmentStart,
        endWeek: projections.length,
      ));
    }

    final totalWeeks = projections.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timeline bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 24,
            child: Row(
              children: segments.map((segment) {
                final flex = segment.endWeek - segment.startWeek + 1;
                return Expanded(
                  flex: flex,
                  child: Container(
                    color: segment.zone.color,
                    alignment: Alignment.center,
                    child: flex > 10
                        ? Text(
                            '${segment.startWeek}-${segment.endWeek}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Week labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Minggu 1', style: TextStyle(fontSize: 10)),
            Text('Minggu $totalWeeks', style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class _TimelineSegment {
  final ExitZone zone;
  final int startWeek;
  final int endWeek;

  _TimelineSegment({
    required this.zone,
    required this.startWeek,
    required this.endWeek,
  });
}

/// Key milestones view
class _KeyMilestones extends StatelessWidget {
  final dynamic result;

  const _KeyMilestones({required this.result});

  @override
  Widget build(BuildContext context) {
    final milestones = result.milestoneWeeks as List<WeeklyProjection>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titik-Titik Penting',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...milestones.take(6).map((week) => _MilestoneItem(week: week)),
      ],
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final WeeklyProjection week;

  const _MilestoneItem({required this.week});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: week.zone.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(week.weekLabel),
          ),
          Text(
            week.endingBalanceFormatted,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: week.zone.color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: week.zone.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              week.zone.nameId,
              style: TextStyle(
                fontSize: 10,
                color: week.zone.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detailed weekly list
class _WeeklyList extends StatelessWidget {
  final List<WeeklyProjection> projections;

  const _WeeklyList({required this.projections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Mingguan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.grey.shade100,
          child: const Row(
            children: [
              SizedBox(width: 60, child: Text('Minggu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(child: Text('Saldo Akhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              SizedBox(width: 60, child: Text('Zona', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
            ],
          ),
        ),

        // Week rows - show every 4th week for readability
        ...projections.where((p) => p.weekNumber % 4 == 0 || p.weekNumber == 1).map(
              (week) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        week.weekLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        week.endingBalanceFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: week.zone.color,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: week.zone.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          week.zone.nameId,
                          style: TextStyle(
                            fontSize: 10,
                            color: week.zone.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
