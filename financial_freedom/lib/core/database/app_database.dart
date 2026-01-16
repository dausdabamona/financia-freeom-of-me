import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'package:financial_freedom/core/database/tables/tables.dart';
import 'package:financial_freedom/core/database/daos/account_dao.dart';
import 'package:financial_freedom/core/database/daos/transaction_dao.dart';
import 'package:financial_freedom/core/database/daos/asset_dao.dart';
import 'package:financial_freedom/core/database/daos/liability_dao.dart';
import 'package:financial_freedom/core/database/daos/monthly_baseline_dao.dart';
import 'package:financial_freedom/core/database/daos/financial_snapshot_dao.dart';
import 'package:financial_freedom/core/database/daos/daily_compass_dao.dart';
import 'package:financial_freedom/core/database/daos/time_profile_dao.dart';

part 'app_database.g.dart';

/// Financial Freedom App Database
///
/// Uses SQLCipher for encryption - all data is encrypted at rest.
/// This is critical for financial data privacy.
///
/// Schema Version History:
/// - v1: Initial schema with all Reality Engine tables
/// - v2: Added TimeProfiles table for time freedom tracking
@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
    Assets,
    Liabilities,
    MonthlyBaselines,
    FinancialSnapshots,
    DailyCompass,
    TimeProfiles,
  ],
  daos: [
    AccountDao,
    TransactionDao,
    AssetDao,
    LiabilityDao,
    MonthlyBaselineDao,
    FinancialSnapshotDao,
    DailyCompassDao,
    TimeProfileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  // Lazy-initialized DAOs
  late final accountDao = AccountDao(this);
  late final transactionDao = TransactionDao(this);
  late final assetDao = AssetDao(this);
  late final liabilityDao = LiabilityDao(this);
  late final monthlyBaselineDao = MonthlyBaselineDao(this);
  late final financialSnapshotDao = FinancialSnapshotDao(this);
  late final dailyCompassDao = DailyCompassDao(this);
  late final timeProfileDao = TimeProfileDao(this);

  /// Creates an encrypted database instance.
  /// Encryption key is stored securely in device keychain.
  static Future<AppDatabase> create() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'financial_freedom.db'));

    // Get or create encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();

    return AppDatabase(_openEncryptedDatabase(file, encryptionKey));
  }

  /// Creates an in-memory database for testing.
  static AppDatabase createInMemory() {
    return AppDatabase(NativeDatabase.memory());
  }

  /// Retrieves existing key or creates new one.
  /// Key is stored in secure storage (Keychain on iOS, Keystore on Android).
  static Future<String> _getOrCreateEncryptionKey() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    const keyName = 'financial_freedom_db_key';
    String? key = await storage.read(key: keyName);

    if (key == null) {
      // Generate a secure 32-character key
      key = _generateSecureKey();
      await storage.write(key: keyName, value: key);
    }

    return key;
  }

  /// Generates a cryptographically secure key.
  static String _generateSecureKey() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Opens database with SQLCipher encryption.
  static QueryExecutor _openEncryptedDatabase(File file, String encryptionKey) {
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Load SQLCipher
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

        // Set encryption key - PRAGMA key must be first command
        db.execute("PRAGMA key = '$encryptionKey'");

        // Verify encryption is working
        db.execute('SELECT count(*) FROM sqlite_master');
      },
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here as schema evolves
        if (from < 2) {
          await m.createTable(timeProfiles);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
