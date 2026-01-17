import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:financial_freedom/ui/bloc/ppk/ppk_bloc.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Halaman Dashboard PPK
///
/// Menampilkan ringkasan status UP dan TUP serta
/// notifikasi yang memerlukan perhatian.
class PpkDashboardPage extends StatelessWidget {
  const PpkDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PpkDashboardBloc()
        ..add(LoadPpkDashboard(tahunAnggaran: DateTime.now().year.toString())),
      child: const _PpkDashboardView(),
    );
  }
}

class _PpkDashboardView extends StatelessWidget {
  const _PpkDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten PPK'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PpkDashboardBloc>().add(const RefreshPpkDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<PpkDashboardBloc, PpkDashboardState>(
        builder: (context, state) {
          if (state is PpkDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PpkDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PpkDashboardBloc>().add(
                            LoadPpkDashboard(
                              tahunAnggaran: DateTime.now().year.toString(),
                            ),
                          );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is PpkDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PpkDashboardBloc>().add(const RefreshPpkDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: 24),
                    _buildSummaryCards(context, state),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    if (state.hasOverdueSpj) _buildAlerts(context, state),
                    const SizedBox(height: 24),
                    _buildStatusSummary(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Pengajuan Baru'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PpkDashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'Tahun Anggaran ${state.tahunAnggaran}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Dana Dicairkan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(state.totalDicairkan),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, PpkDashboardLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total UP',
            value: state.totalUpAktif.toString(),
            subtitle: NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(state.totalUpDicairkan),
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/ppk/up'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total TUP',
            value: state.totalTupAktif.toString(),
            subtitle: NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(state.totalTupDicairkan),
            icon: Icons.add_card,
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/ppk/tup'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Ajukan UP',
                onTap: () => Navigator.pushNamed(context, '/ppk/up/create'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_card,
                label: 'Ajukan TUP',
                onTap: () => Navigator.pushNamed(context, '/ppk/tup/create'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: 'Riwayat',
                onTap: () => Navigator.pushNamed(context, '/ppk/history'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'SPJ',
                onTap: () => Navigator.pushNamed(context, '/ppk/spj'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlerts(BuildContext context, PpkDashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Perlu Perhatian',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.upOverdueSpj.isNotEmpty)
            _AlertItem(
              text: '${state.upOverdueSpj.length} UP melewati batas waktu SPJ',
              onTap: () {},
            ),
          if (state.tupOverdueSpj.isNotEmpty)
            _AlertItem(
              text: '${state.tupOverdueSpj.length} TUP melewati batas waktu SPJ',
              onTap: () {},
            ),
          if (state.tupNeedReturn.isNotEmpty)
            _AlertItem(
              text:
                  '${state.tupNeedReturn.length} TUP perlu pengembalian sisa dana',
              onTap: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(BuildContext context, PpkDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusCard('Uang Persediaan (UP)', state.summaryUpByStatus),
        const SizedBox(height: 12),
        _buildStatusCard('Tambahan UP (TUP)', state.summaryTupByStatus),
      ],
    );
  }

  Widget _buildStatusCard(String title, Map<StatusPersetujuan, int> summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.entries.map((entry) {
                return _StatusChip(
                  status: entry.key,
                  count: entry.value,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buat Pengajuan Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.account_balance_wallet, color: Colors.white),
                ),
                title: const Text('Uang Persediaan (UP)'),
                subtitle: const Text('Pengajuan uang muka kerja operasional'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ppk/up/create');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.add_card, color: Colors.white),
                ),
                title: const Text('Tambahan UP (TUP)'),
                subtitle: const Text('Pengajuan tambahan untuk kebutuhan mendesak'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ppk/tup/create');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AlertItem({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red.shade700),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final StatusPersetujuan status;
  final int count;

  const _StatusChip({
    required this.status,
    required this.count,
  });

  Color get _color {
    switch (status) {
      case StatusPersetujuan.draft:
        return Colors.grey;
      case StatusPersetujuan.diajukan:
        return Colors.blue;
      case StatusPersetujuan.diverifikasi:
        return Colors.indigo;
      case StatusPersetujuan.menungguPersetujuanKpa:
        return Colors.purple;
      case StatusPersetujuan.disetujuiKpa:
        return Colors.teal;
      case StatusPersetujuan.ditolak:
        return Colors.red;
      case StatusPersetujuan.prosesPencairan:
        return Colors.amber;
      case StatusPersetujuan.dicairkan:
        return Colors.green;
      case StatusPersetujuan.prosesSpj:
        return Colors.orange;
      case StatusPersetujuan.selesai:
        return Colors.green.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${status.label}: $count',
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
