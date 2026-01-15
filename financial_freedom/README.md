# Financial Freedom

## Visi

**Personal Financial Freedom Compass** — Keluar dari ketergantungan gaji dan meraih kedaulatan waktu.

Ini bukan sekadar aplikasi pencatat keuangan. Ini adalah kompas yang memandu perjalanan Anda keluar dari *rat race* menuju kehidupan di mana waktu Anda adalah milik Anda sendiri.

---

## Filosofi

> *"Kebebasan finansial bukan tentang menjadi kaya. Ini tentang memiliki pilihan untuk tidak bekerja jika Anda tidak mau."*

Aplikasi ini dibangun dengan prinsip:

1. **Kesadaran Realitas** — Ketahui posisi Anda sekarang tanpa ilusi
2. **Arah yang Jelas** — Lihat jalan keluar, bukan hanya angka-angka
3. **Langkah Kecil Setiap Hari** — Fokus pada aksi yang bisa dilakukan hari ini
4. **Privasi Mutlak** — Data keuangan Anda terenkripsi dan tetap di perangkat Anda

---

## Arsitektur

```
lib/
├── core/                 # Fondasi aplikasi
│   ├── constants/        # Konstanta aplikasi
│   ├── database/         # Encrypted SQLite (SQLCipher)
│   ├── di/               # Dependency injection
│   ├── errors/           # Failures & exceptions
│   └── usecases/         # Base use case class
│
├── domain/               # Business logic (pure Dart)
│   ├── entities/         # Domain models
│   ├── repositories/     # Repository contracts
│   └── usecases/         # Application use cases
│
├── data/                 # Data implementation
│   ├── datasources/      # Local & remote data sources
│   │   └── local/        # SQLite implementation
│   ├── models/           # Data transfer objects
│   └── repositories/     # Repository implementations
│
├── ui/                   # Presentation layer
│   ├── bloc/             # State management (BLoC)
│   ├── pages/            # Screen widgets
│   └── widgets/          # Reusable UI components
│
└── backup/               # Encrypted backup system
```

---

## Teknologi

| Kategori | Library | Alasan |
|----------|---------|--------|
| Database | **Drift + SQLCipher** | Offline-first, terenkripsi penuh |
| State Management | **flutter_bloc** | Predictable, testable |
| DI | **get_it + injectable** | Simple, powerful |
| Functional | **dartz** | Either type untuk error handling |
| Security | **flutter_secure_storage** | Keychain/Keystore untuk kunci enkripsi |

---

## Fitur (Roadmap)

### Tahap 1: Reality Engine
- [ ] Skema database final
- [ ] Burn Rate (pengeluaran harian)
- [ ] Runway (berapa lama bisa bertahan tanpa gaji)
- [ ] Salary Dependency (% ketergantungan pada gaji)
- [ ] Layar "Langkah Kecil Hari Ini"

### Tahap 2: Exit Navigation Engine
- [ ] Freedom Phase (Trapped → Free)
- [ ] Daily Compass (prioritas hari ini)
- [ ] Progress tracking

### Tahap 3: Backup System
- [ ] Encrypted manual backup
- [ ] Export ke Google Drive (manual, bukan sync)
- [ ] Import & restore

---

## Prinsip Desain

1. **Offline-First**: Semua data tersimpan lokal, tidak ada ketergantungan internet
2. **Privacy by Design**: Enkripsi end-to-end, kunci di secure storage perangkat
3. **Clean Architecture**: Separation of concerns, mudah di-test dan di-maintain
4. **No Tracking**: Tidak ada analytics, tidak ada data yang dikirim ke server

---

## Memulai

```bash
# Install dependencies
flutter pub get

# Generate code (database, DI)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

## Lisensi

Private project — Hak cipta dilindungi.

---

*"Perjalanan seribu mil dimulai dengan satu langkah kecil hari ini."*
