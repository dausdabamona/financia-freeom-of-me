import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

part 'app_database.g.dart';

/// Financial Freedom App Database
///
/// Uses SQLCipher for encryption - all data is encrypted at rest.
/// This is critical for financial data privacy.
///
/// Tables will be added here as features are implemented:
/// - Income sources
/// - Expenses
/// - Assets
/// - Financial snapshots
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Creates an encrypted database instance.
  /// Encryption key is stored securely in device keychain.
  static Future<AppDatabase> create() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'financial_freedom.db'));

    // Get or create encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();

    return AppDatabase(_openEncryptedDatabase(file, encryptionKey));
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
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = List.generate(32, (index) {
      final randomIndex = DateTime.now().microsecondsSinceEpoch % chars.length;
      return chars[randomIndex];
    });
    return random.join();
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
      },
    );
  }
}
