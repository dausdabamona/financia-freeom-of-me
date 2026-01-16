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
├── core/                     # Fondasi aplikasi
│   ├── constants/            # Konstanta aplikasi
│   ├── database/             # Encrypted SQLite (SQLCipher)
│   │   ├── tables/           # Drift table definitions
│   │   └── daos/             # Data Access Objects
│   ├── di/                   # Dependency injection
│   ├── errors/               # Failures & exceptions
│   ├── services/             # Core services (FreedomCalculator)
│   └── usecases/             # Base use case class
│
├── domain/                   # Business logic (pure Dart)
│   ├── entities/             # Domain models
│   ├── repositories/         # Repository contracts
│   └── usecases/             # Application use cases
│
├── data/                     # Data implementation
│   ├── mappers/              # DB <-> Domain mappers
│   └── repositories/         # Repository implementations
│
├── ui/                       # Presentation layer
│   ├── bloc/                 # State management (BLoC)
│   │   └── compass/          # Compass BLoC
│   └── pages/                # Screen widgets
│       └── home/             # Home compass page
│
└── backup/                   # Encrypted backup system
```

---

## Teknologi

| Kategori | Library | Alasan |
|----------|---------|--------|
| Database | **Drift + SQLCipher** | Offline-first, terenkripsi penuh |
| State Management | **flutter_bloc** | Predictable, testable |
| DI | **get_it** | Simple, powerful |
| Functional | **dartz** | Either type untuk error handling |
| Security | **flutter_secure_storage** | Keychain/Keystore untuk kunci enkripsi |

---

## Phase 1: Reality Engine (Implemented)

Reality Engine adalah jantung dari Financial Freedom Compass. Ia membaca seluruh data keuangan dan menghitung "realita" posisi finansial Anda.

### Database Schema

7 tabel untuk melacak semua aspek keuangan:

| Tabel | Fungsi |
|-------|--------|
| `accounts` | Akun keuangan (bank, e-wallet, tunai, investasi) |
| `transactions` | Pemasukan dan pengeluaran |
| `assets` | Aset yang dimiliki (properti, saham, dll) |
| `liabilities` | Utang dan kewajiban |
| `monthly_baselines` | Baseline pengeluaran bulanan |
| `financial_snapshots` | Snapshot harian kondisi keuangan |
| `daily_compass` | Panduan langkah kecil harian |

### Core Calculations

```dart
// Burn Rate (pengeluaran bulanan)
burn_rate = essential_cost + optional_cost + debt_payments + safety_buffer

// Runway (berapa bulan bisa bertahan tanpa gaji)
runway_months = total_liquid_assets / burn_rate

// Salary Dependency Ratio (0.0 - 1.0)
salary_dependency = salary_income / total_monthly_income

// Time Freedom Index (0.0 - 1.0)
time_freedom = free_hours_per_week / 168
```

### Freedom Phases

| Phase | Kondisi | Deskripsi |
|-------|---------|-----------|
| **BOUND** | runway < 6 OR salary_dep > 70% | Masih terikat pada gaji aktif |
| **TRANSITION** | runway 6-18 AND salary_dep 30-70% | Sedang membangun jalan keluar |
| **INDEPENDENT** | runway > 18 AND salary_dep < 30% | Bisa bertahan lama tanpa gaji |
| **OPTIONAL** | passive_income >= burn_rate | Bekerja adalah pilihan |
| **FREE** | passive >= burn_rate AND time > 50% | Kebebasan penuh |

### Daily Compass

Setiap hari, aplikasi memberi satu "langkah kecil" berdasarkan kondisi:

| Prioritas | Kondisi | Focus Domain |
|-----------|---------|--------------|
| 1 | runway < 6 OR salary_dep > 70% | A_FINANCIAL |
| 2 | emotional_pressure_high | C_PSYCHOLOGICAL |
| 3 | Default | B_TIME_SYSTEM |

**Tone pesan**: Akrab, Jujur, Navigator tegas + sahabat + mentor

Contoh:
> "Kamu aman 7,3 bulan tanpa gaji. Kita masih di fase transisi. Hari ini, satu langkah kecil: kurangi satu pengeluaran yang tidak menambah kebebasan."

### UI: Home Compass Page

Layar utama menampilkan:
- **Freedom Phase** dengan warna indikator
- **Key Metrics**: Runway, Salary Dependency, Passive Income, Net Worth
- **Situation Message**: Penjelasan kondisi saat ini
- **Daily Compass**: Langkah kecil hari ini dengan tombol "Sudah Dilakukan"

---

## Fitur (Roadmap)

### Tahap 1: Reality Engine ✅
- [x] Skema database (7 tabel)
- [x] Burn Rate calculation
- [x] Runway calculation
- [x] Salary Dependency Ratio
- [x] Time Freedom Index
- [x] Freedom Phase determination
- [x] Daily Compass generation
- [x] Home Compass Page UI
- [x] FreedomCalculator service
- [x] GenerateDailySnapshotUseCase

### Tahap 2: Data Entry (Next)
- [ ] Form input akun
- [ ] Form input transaksi
- [ ] Form input baseline bulanan
- [ ] Form input aset & liabilitas
- [ ] Validasi dan error handling

### Tahap 3: Progress Tracking
- [ ] Historical snapshots chart
- [ ] Freedom phase progress
- [ ] Completion rate tracking

### Tahap 4: Backup System
- [ ] Encrypted manual backup
- [ ] Export ke Google Drive (manual)
- [ ] Import & restore

---

## Prinsip Desain

1. **Offline-First**: Semua data tersimpan lokal, tidak ada ketergantungan internet
2. **Privacy by Design**: Enkripsi end-to-end, kunci di secure storage perangkat
3. **Clean Architecture**: Separation of concerns, mudah di-test dan di-maintain
4. **No Tracking**: Tidak ada analytics, tidak ada data yang dikirim ke server
5. **Navigator, not Judge**: Aplikasi memandu, bukan menghakimi keputusan finansial

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

## Struktur Use Cases

```
GenerateDailySnapshotUseCase
├── Read financial data from all tables
├── Calculate metrics via FreedomCalculator
├── Determine freedom phase
├── Generate daily compass entry
├── Save snapshot to database
└── Return DailySnapshotResult (snapshot + compass)
```

---

## Lisensi

Private project — Hak cipta dilindungi.

---

*"Perjalanan seribu mil dimulai dengan satu langkah kecil hari ini."*
