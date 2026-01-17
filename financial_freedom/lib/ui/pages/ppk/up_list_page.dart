import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:financial_freedom/ui/bloc/ppk/ppk_bloc.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Halaman daftar Uang Persediaan (UP)
class UpListPage extends StatelessWidget {
  const UpListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PengajuanUpBloc()..add(const LoadAllUp()),
      child: const _UpListView(),
    );
  }
}

class _UpListView extends StatefulWidget {
  const _UpListView();

  @override
  State<_UpListView> createState() => _UpListViewState();
}

class _UpListViewState extends State<_UpListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uang Persediaan (UP)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Draft'),
            Tab(text: 'Proses'),
            Tab(text: 'Selesai'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<PengajuanUpBloc, PengajuanUpState>(
        listener: (context, state) {
          if (state is PengajuanUpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PengajuanUpLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PengajuanUpListLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildUpList(state.listUp),
                _buildUpList(state.listUp
                    .where((up) => up.status == StatusPersetujuan.draft)
                    .toList()),
                _buildUpList(state.listUp
                    .where((up) =>
                        up.status != StatusPersetujuan.draft &&
                        up.status != StatusPersetujuan.selesai &&
                        up.status != StatusPersetujuan.ditolak)
                    .toList()),
                _buildUpList(state.listUp
                    .where((up) =>
                        up.status == StatusPersetujuan.selesai ||
                        up.status == StatusPersetujuan.ditolak)
                    .toList()),
              ],
            );
          }

          return const Center(child: Text('Tidak ada data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/ppk/up/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpList(List<UangPersediaan> listUp) {
    if (listUp.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data UP',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PengajuanUpBloc>().add(const LoadAllUp());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listUp.length,
        itemBuilder: (context, index) {
          return _UpCard(up: listUp[index]);
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tahun Anggaran'),
                trailing: DropdownButton<String>(
                  value: DateTime.now().year.toString(),
                  items: [
                    for (var year = DateTime.now().year; year >= 2020; year--)
                      DropdownMenuItem(
                        value: year.toString(),
                        child: Text(year.toString()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<PengajuanUpBloc>()
                          .add(LoadAllUp(tahunAnggaran: value));
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

class _UpCard extends StatelessWidget {
  final UangPersediaan up;

  const _UpCard({required this.up});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/ppk/up/detail',
          arguments: up.id,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    up.nomorPengajuan,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _StatusBadge(status: up.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                up.uraianPenggunaan,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: DateFormat('dd/MM/yyyy').format(up.tanggalPengajuan),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.attach_money,
                    label: currencyFormat.format(up.jumlahPengajuan),
                  ),
                ],
              ),
              if (up.status == StatusPersetujuan.dicairkan ||
                  up.status == StatusPersetujuan.prosesSpj) ...[
                const SizedBox(height: 12),
                _buildProgressSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final progress = up.jumlahDisetujui > 0
        ? up.jumlahDipertanggungjawabkan / up.jumlahDisetujui
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress SPJ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            minHeight: 6,
          ),
        ),
        if (up.batasWaktuSpj != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                up.isOverdueSpj ? Icons.warning : Icons.access_time,
                size: 14,
                color: up.isOverdueSpj
                    ? Colors.red
                    : up.isNearSpjDeadline
                        ? Colors.orange
                        : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                up.isOverdueSpj
                    ? 'Overdue ${-up.sisaHariSpj} hari'
                    : 'Sisa ${up.sisaHariSpj} hari',
                style: TextStyle(
                  fontSize: 12,
                  color: up.isOverdueSpj
                      ? Colors.red
                      : up.isNearSpjDeadline
                          ? Colors.orange
                          : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusPersetujuan status;

  const _StatusBadge({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
