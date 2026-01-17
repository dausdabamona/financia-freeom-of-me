import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';
import 'pengajuan_up_event.dart';
import 'pengajuan_up_state.dart';

/// BLoC untuk mengelola pengajuan Uang Persediaan (UP)
///
/// Menangani seluruh siklus hidup pengajuan UP mulai dari
/// pembuatan draft hingga penyelesaian SPJ.
class PengajuanUpBloc extends Bloc<PengajuanUpEvent, PengajuanUpState> {
  // Dalam implementasi nyata, inject repository melalui constructor
  // final UangPersediaanRepository _repository;

  PengajuanUpBloc() : super(const PengajuanUpInitial()) {
    on<LoadAllUp>(_onLoadAllUp);
    on<LoadUpByStatus>(_onLoadUpByStatus);
    on<LoadUpDetail>(_onLoadUpDetail);
    on<CreateUp>(_onCreateUp);
    on<UpdateUp>(_onUpdateUp);
    on<SubmitUp>(_onSubmitUp);
    on<VerifyUp>(_onVerifyUp);
    on<ApproveUp>(_onApproveUp);
    on<RejectUp>(_onRejectUp);
    on<DisburseUp>(_onDisburseUp);
    on<UpdateUpUsage>(_onUpdateUpUsage);
    on<UpdateUpSpj>(_onUpdateUpSpj);
    on<CompleteUp>(_onCompleteUp);
    on<DeleteUp>(_onDeleteUp);
  }

  Future<void> _onLoadAllUp(
    LoadAllUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      // Dalam implementasi nyata, ambil data dari repository
      await Future.delayed(const Duration(milliseconds: 300));

      emit(PengajuanUpListLoaded(
        listUp: _getDummyUpList(),
        filterTahun: event.tahunAnggaran,
      ));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memuat data UP: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUpByStatus(
    LoadUpByStatus event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final allUp = _getDummyUpList();
      final filteredUp = allUp.where((up) => up.status == event.status).toList();

      emit(PengajuanUpListLoaded(listUp: filteredUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memuat data UP: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUpDetail(
    LoadUpDetail event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final up = _getDummyUpList().firstWhere(
        (u) => u.id == event.id,
        orElse: () => throw Exception('UP tidak ditemukan'),
      );

      emit(PengajuanUpDetailLoaded(up: up));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memuat detail UP: ${e.toString()}'));
    }
  }

  Future<void> _onCreateUp(
    CreateUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      emit(PengajuanUpCreated(up: event.up));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal membuat UP: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUp(
    UpdateUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      emit(PengajuanUpUpdated(up: event.up));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memperbarui UP: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitUp(
    SubmitUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.diajukan,
        catatanPpk: event.catatan,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpSubmitted(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal mengajukan UP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyUp(
    VerifyUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.diverifikasi,
        catatanBendahara: event.catatan,
        tanggalVerifikasi: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpVerified(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memverifikasi UP: ${e.toString()}'));
    }
  }

  Future<void> _onApproveUp(
    ApproveUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.disetujuiKpa,
        jumlahDisetujui: event.jumlahDisetujui,
        catatanKpa: event.catatan,
        tanggalPersetujuanKpa: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpApproved(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal menyetujui UP: ${e.toString()}'));
    }
  }

  Future<void> _onRejectUp(
    RejectUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.ditolak,
        alasanPenolakan: event.alasanPenolakan,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpRejected(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal menolak UP: ${e.toString()}'));
    }
  }

  Future<void> _onDisburseUp(
    DisburseUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.dicairkan,
        tanggalPencairan: event.tanggalPencairan,
        batasWaktuSpj: event.batasWaktuSpj,
        sisaUp: up.jumlahDisetujui,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpDisbursed(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal mencairkan UP: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUpUsage(
    UpdateUpUsage event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        jumlahTerpakai: event.jumlahTerpakai,
        sisaUp: up.jumlahDisetujui - event.jumlahTerpakai,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpUpdated(
        up: updatedUp,
        message: 'Penggunaan UP berhasil diperbarui',
      ));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memperbarui penggunaan UP: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUpSpj(
    UpdateUpSpj event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        jumlahDipertanggungjawabkan: event.jumlahDipertanggungjawabkan,
        status: StatusPersetujuan.prosesSpj,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpUpdated(
        up: updatedUp,
        message: 'SPJ UP berhasil diperbarui',
      ));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal memperbarui SPJ UP: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteUp(
    CompleteUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final up = _getDummyUpList().firstWhere((u) => u.id == event.id);
      final updatedUp = up.copyWith(
        status: StatusPersetujuan.selesai,
        updatedAt: DateTime.now(),
      );

      emit(PengajuanUpCompleted(up: updatedUp));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal menyelesaikan UP: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUp(
    DeleteUp event,
    Emitter<PengajuanUpState> emit,
  ) async {
    emit(const PengajuanUpLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      emit(PengajuanUpDeleted(id: event.id));
    } catch (e) {
      emit(PengajuanUpError(message: 'Gagal menghapus UP: ${e.toString()}'));
    }
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
      UangPersediaan(
        id: '2',
        nomorPengajuan: 'UP-2024-002',
        tanggalPengajuan: DateTime(2024, 2, 1),
        jenisUp: JenisUp.tunai,
        jumlahPengajuan: 30000000,
        tahunAnggaran: '2024',
        kodeSatker: '032001',
        namaSatker: 'Direktorat Jenderal Perikanan Tangkap',
        kodeProgram: '032.01.01',
        namaProgram: 'Program Pengelolaan Perikanan',
        kodeKegiatan: '2346',
        namaKegiatan: 'Pengawasan Sumber Daya Ikan',
        kodeOutput: '002',
        namaOutput: 'Pengawasan Kapal',
        kodeAkun: '521211',
        namaAkun: 'Belanja Bahan',
        uraianPenggunaan: 'Untuk keperluan operasional pengawasan kapal',
        status: StatusPersetujuan.draft,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      ),
    ];
  }
}
