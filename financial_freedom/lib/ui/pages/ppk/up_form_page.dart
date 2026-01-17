import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom/ui/bloc/ppk/ppk_bloc.dart';
import 'package:financial_freedom/domain/entities/ppk/uang_persediaan.dart';
import 'package:financial_freedom/domain/entities/ppk/status_persetujuan.dart';

/// Halaman form pengajuan Uang Persediaan (UP)
class UpFormPage extends StatelessWidget {
  final String? upId;

  const UpFormPage({super.key, this.upId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PengajuanUpBloc(),
      child: _UpFormView(upId: upId),
    );
  }
}

class _UpFormView extends StatefulWidget {
  final String? upId;

  const _UpFormView({this.upId});

  @override
  State<_UpFormView> createState() => _UpFormViewState();
}

class _UpFormViewState extends State<_UpFormView> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _uraianController = TextEditingController();
  final _kodeSatkerController = TextEditingController();
  final _namaSatkerController = TextEditingController();
  final _kodeProgramController = TextEditingController();
  final _namaProgramController = TextEditingController();
  final _kodeKegiatanController = TextEditingController();
  final _namaKegiatanController = TextEditingController();
  final _kodeOutputController = TextEditingController();
  final _namaOutputController = TextEditingController();
  final _kodeAkunController = TextEditingController();
  final _namaAkunController = TextEditingController();

  JenisUp _jenisUp = JenisUp.tunai;
  int _currentStep = 0;

  bool get isEditing => widget.upId != null;

  @override
  void dispose() {
    _jumlahController.dispose();
    _uraianController.dispose();
    _kodeSatkerController.dispose();
    _namaSatkerController.dispose();
    _kodeProgramController.dispose();
    _namaProgramController.dispose();
    _kodeKegiatanController.dispose();
    _namaKegiatanController.dispose();
    _kodeOutputController.dispose();
    _namaOutputController.dispose();
    _kodeAkunController.dispose();
    _namaAkunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit UP' : 'Pengajuan UP Baru'),
      ),
      body: BlocConsumer<PengajuanUpBloc, PengajuanUpState>(
        listener: (context, state) {
          if (state is PengajuanUpCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
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

          return Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (_currentStep < 2)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('Lanjut'),
                        )
                      else
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Simpan'),
                        ),
                      const SizedBox(width: 8),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Kembali'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                _buildInfoDasarStep(),
                _buildInfoAnggaranStep(),
                _buildRincianStep(),
              ],
            ),
          );
        },
      ),
    );
  }

  Step _buildInfoDasarStep() {
    return Step(
      title: const Text('Informasi Dasar'),
      subtitle: const Text('Jenis UP dan Satker'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Uang Persediaan',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SegmentedButton<JenisUp>(
            segments: JenisUp.values.map((jenis) {
              return ButtonSegment<JenisUp>(
                value: jenis,
                label: Text(jenis.label),
              );
            }).toList(),
            selected: {_jenisUp},
            onSelectionChanged: (selected) {
              setState(() => _jenisUp = selected.first);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _kodeSatkerController,
            decoration: const InputDecoration(
              labelText: 'Kode Satker',
              hintText: 'Contoh: 032001',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kode satker wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _namaSatkerController,
            decoration: const InputDecoration(
              labelText: 'Nama Satker',
              hintText: 'Contoh: Direktorat Jenderal Perikanan Tangkap',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama satker wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Step _buildInfoAnggaranStep() {
    return Step(
      title: const Text('Informasi Anggaran'),
      subtitle: const Text('Program, Kegiatan, Output, Akun'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _kodeProgramController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Program',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _namaProgramController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Program',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _kodeKegiatanController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Kegiatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _namaKegiatanController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kegiatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _kodeOutputController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Output',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _namaOutputController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Output',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _kodeAkunController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Akun',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _namaAkunController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Akun',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Step _buildRincianStep() {
    return Step(
      title: const Text('Rincian Pengajuan'),
      subtitle: const Text('Jumlah dan uraian penggunaan'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        children: [
          TextFormField(
            controller: _jumlahController,
            decoration: const InputDecoration(
              labelText: 'Jumlah Pengajuan (Rp)',
              hintText: '0',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah pengajuan wajib diisi';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _uraianController,
            decoration: const InputDecoration(
              labelText: 'Uraian Penggunaan',
              hintText: 'Jelaskan tujuan penggunaan UP',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Uraian penggunaan wajib diisi';
              }
              if (value.length < 20) {
                return 'Uraian terlalu pendek (minimal 20 karakter)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Setelah disimpan, pengajuan akan berstatus "Draft". '
                    'Anda dapat mengajukan ke Bendahara untuk diverifikasi.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tahunAnggaran = DateTime.now().year.toString();
      final nomorPengajuan =
          'UP-$tahunAnggaran-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      final up = UangPersediaan(
        id: const Uuid().v4(),
        nomorPengajuan: nomorPengajuan,
        tanggalPengajuan: DateTime.now(),
        jenisUp: _jenisUp,
        jumlahPengajuan: double.parse(_jumlahController.text),
        tahunAnggaran: tahunAnggaran,
        kodeSatker: _kodeSatkerController.text,
        namaSatker: _namaSatkerController.text,
        kodeProgram: _kodeProgramController.text,
        namaProgram: _namaProgramController.text,
        kodeKegiatan: _kodeKegiatanController.text,
        namaKegiatan: _namaKegiatanController.text,
        kodeOutput: _kodeOutputController.text,
        namaOutput: _namaOutputController.text,
        kodeAkun: _kodeAkunController.text,
        namaAkun: _namaAkunController.text,
        uraianPenggunaan: _uraianController.text,
        status: StatusPersetujuan.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<PengajuanUpBloc>().add(CreateUp(up: up));
    }
  }
}
