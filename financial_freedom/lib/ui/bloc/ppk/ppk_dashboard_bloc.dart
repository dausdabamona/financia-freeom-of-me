import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/tambahan_uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';
import 'ppk_dashboard_event.dart';
import 'ppk_dashboard_state.dart';

/// BLoC untuk PPK Dashboard
///
/// Mengelola state dashboard PPK yang menampilkan ringkasan
/// UP dan TUP serta notifikasi yang perlu perhatian.
class PpkDashboardBloc extends Bloc<PpkDashboardEvent, PpkDashboardState> {
  // Dalam implementasi nyata, inject repository melalui constructor
  // final UangPersediaanRepository _upRepository;
  // final TambahanUangPersediaanRepository _tupRepository;

  PpkDashboardBloc() : super(const PpkDashboardInitial()) {
    on<LoadPpkDashboard>(_onLoadDashboard);
    on<RefreshPpkDashboard>(_onRefreshDashboard);
    on<FilterByTahunAnggaran>(_onFilterByTahunAnggaran);
  }

  Future<void> _onLoadDashboard(
    LoadPpkDashboard event,
    Emitter<PpkDashboardState> emit,
  ) async {
    emit(const PpkDashboardLoading());

    try {
      // Dalam implementasi nyata, data diambil dari repository
      // Untuk sementara, gunakan data dummy
      await Future.delayed(const Duration(milliseconds: 500));

      emit(PpkDashboardLoaded(
        tahunAnggaran: event.tahunAnggaran,
        listUp: _getDummyUpList(),
        listTup: _getDummyTupList(),
        summaryUpByStatus: _getDummyUpSummary(),
        summaryTupByStatus: _getDummyTupSummary(),
        totalUpDicairkan: 150000000,
        totalTupDicairkan: 75000000,
        upPendingSpj: [],
        tupPendingSpj: [],
        upOverdueSpj: [],
        tupOverdueSpj: [],
        tupNeedReturn: [],
        totalSisaTupBelumDikembalikan: 0,
      ));
    } catch (e) {
      emit(PpkDashboardError(message: 'Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshPpkDashboard event,
    Emitter<PpkDashboardState> emit,
  ) async {
    if (state is PpkDashboardLoaded) {
      final currentState = state as PpkDashboardLoaded;
      add(LoadPpkDashboard(tahunAnggaran: currentState.tahunAnggaran));
    }
  }

  Future<void> _onFilterByTahunAnggaran(
    FilterByTahunAnggaran event,
    Emitter<PpkDashboardState> emit,
  ) async {
    add(LoadPpkDashboard(tahunAnggaran: event.tahunAnggaran));
  }

  // Dummy data untuk testing
  List<UangPersediaan> _getDummyUpList() {
    return [
      UangPersediaan(
        id: '1',
        nomorPengajuan: 'UP-2024-001',
        tanggalPengajuan: DateTime(2024, 1, 15),
        jenisUp: JenisUp.tunai,
        jumlahPengajuan: 50000000,
        jumlahDisetujui: 50000000,
        tahunAnggaran: '2024',
        kodeSatker: '032001',
        namaSatker: 'Direktorat Jenderal Perikanan Tangkap',
        kodeProgram: '032.01.01',
        namaProgram: 'Program Pengelolaan Perikanan',
        kodeKegiatan: '2345',
        namaKegiatan: 'Pengelolaan Sumber Daya Ikan',
        kodeOutput: '001',
        namaOutput: 'Layanan Perizinan',
        kodeAkun: '521111',
        namaAkun: 'Belanja Keperluan Perkantoran',
        uraianPenggunaan: 'Untuk keperluan operasional kantor bulan Januari 2024',
        status: StatusPersetujuan.dicairkan,
        tanggalPencairan: DateTime(2024, 1, 20),
        batasWaktuSpj: DateTime(2024, 2, 20),
        jumlahTerpakai: 35000000,
        jumlahDipertanggungjawabkan: 25000000,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 20),
      ),
    ];
  }

  List<TambahanUangPersediaan> _getDummyTupList() {
    return [
      TambahanUangPersediaan(
        id: '1',
        nomorPengajuan: 'TUP-2024-001',
        tanggalPengajuan: DateTime(2024, 2, 1),
        jumlahPengajuan: 75000000,
        jumlahDisetujui: 75000000,
        alasanPengajuan: AlasanTup.kegiatanMendesak,
        uraianAlasan: 'Kegiatan rapat koordinasi nasional perikanan tangkap',
        rincianKebutuhan: 'Akomodasi, konsumsi, dan transportasi peserta',
        tahunAnggaran: '2024',
        kodeSatker: '032001',
        namaSatker: 'Direktorat Jenderal Perikanan Tangkap',
        kodeProgram: '032.01.01',
        namaProgram: 'Program Pengelolaan Perikanan',
        kodeKegiatan: '2345',
        namaKegiatan: 'Pengelolaan Sumber Daya Ikan',
        kodeOutput: '002',
        namaOutput: 'Rapat Koordinasi',
        kodeAkun: '521211',
        namaAkun: 'Belanja Bahan',
        status: StatusPersetujuan.dicairkan,
        tanggalPencairan: DateTime(2024, 2, 5),
        batasWaktuSpj: DateTime(2024, 3, 5),
        jumlahTerpakai: 70000000,
        jumlahDipertanggungjawabkan: 50000000,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 5),
      ),
    ];
  }

  Map<StatusPersetujuan, int> _getDummyUpSummary() {
    return {
      StatusPersetujuan.draft: 2,
      StatusPersetujuan.diajukan: 1,
      StatusPersetujuan.disetujuiKpa: 1,
      StatusPersetujuan.dicairkan: 3,
      StatusPersetujuan.selesai: 5,
    };
  }

  Map<StatusPersetujuan, int> _getDummyTupSummary() {
    return {
      StatusPersetujuan.draft: 1,
      StatusPersetujuan.diajukan: 1,
      StatusPersetujuan.dicairkan: 2,
      StatusPersetujuan.selesai: 3,
    };
  }
}
