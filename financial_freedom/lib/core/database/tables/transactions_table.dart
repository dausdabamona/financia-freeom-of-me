import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/tables/accounts_table.dart';

/// Transaction types
class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';

  static const List<String> values = [income, expense];
}

/// Income categories - berdasarkan format Income Statement
class IncomeCategory {
  // Active income
  static const String salary = 'salary';                // Gaji
  static const String commission = 'commission';        // Komisi, Bonus, Tips
  static const String business = 'business';            // Penghasilan Bersih dari Bisnis
  static const String profession = 'profession';        // Penghasilan dari Profesi

  // Passive income
  static const String interestDividend = 'interest_dividend';  // Bunga dan Deviden
  static const String assetSale = 'asset_sale';                // Penjualan Asset
  static const String rental = 'rental';                       // Penghasilan Sewa

  // Other income
  static const String royalty = 'royalty';              // Royalti
  static const String insurance = 'insurance_income';   // Asuransi jatuh tempo
  static const String pension = 'pension';              // Pensiunan
  static const String other = 'other';                  // Lainnya

  /// Passive income sources (not tied to active work)
  static const List<String> passiveCategories = [
    interestDividend,
    assetSale,
    rental,
    royalty,
    pension,
  ];

  /// Active income sources
  static const List<String> activeCategories = [
    salary,
    commission,
    business,
    profession,
  ];

  static const List<String> values = [
    salary,
    commission,
    business,
    profession,
    interestDividend,
    assetSale,
    rental,
    royalty,
    insurance,
    pension,
    other,
  ];

  /// Indonesian labels for display
  static String nameId(String category) {
    switch (category) {
      case salary: return 'Gaji';
      case commission: return 'Komisi / Bonus / Tips';
      case business: return 'Penghasilan Bisnis';
      case profession: return 'Penghasilan Profesi';
      case interestDividend: return 'Bunga & Deviden';
      case assetSale: return 'Penjualan Aset';
      case rental: return 'Penghasilan Sewa';
      case royalty: return 'Royalti';
      case insurance: return 'Asuransi Jatuh Tempo';
      case pension: return 'Pensiunan';
      case other: return 'Lainnya';
      default: return category;
    }
  }
}

/// Expense categories - berdasarkan format Income Statement
class ExpenseCategory {
  // 1. Sewa / Angsuran
  static const String rent = 'rent';                        // Sewa / Angsuran
  // 2. Biaya Rumah Tangga
  static const String household = 'household';              // Biaya Rumah Tangga
  // 3. Biaya Transport
  static const String transportation = 'transportation';    // Biaya Transport
  // 4. Asuransi
  static const String insurance = 'insurance';              // Asuransi
  // 5. Pajak Penghasilan
  static const String incomeTax = 'income_tax';             // Pajak Penghasilan
  // 6. Pajak Property / Sewa / dll
  static const String propertyTax = 'property_tax';         // Pajak Property
  // 7. Biaya Kesenangan Pribadi
  static const String personalPleasure = 'personal_pleasure'; // Kesenangan Pribadi
  // 8. Biaya Rekreasi Keluarga
  static const String familyRecreation = 'family_recreation'; // Rekreasi Keluarga
  // 9. Hadiah
  static const String gifts = 'gifts';                      // Hadiah
  // 10. Biaya Pendidikan
  static const String education = 'education';              // Pendidikan
  // 11. Perbaikan & Maintenance Asset
  static const String maintenance = 'maintenance';          // Perbaikan & Maintenance
  // 12. Biaya Gaji Pegawai RT
  static const String householdStaff = 'household_staff';   // Gaji Pegawai RT
  // 13. Biaya Keanggotaan Club
  static const String membership = 'membership';            // Keanggotaan Club
  // 14. Biaya Kesehatan
  static const String healthcare = 'healthcare';            // Kesehatan
  // 15. Kontribusi Sosial
  static const String socialContribution = 'social_contribution'; // Kontribusi Sosial
  // 16. Lainnya
  static const String other = 'other';

  /// Essential expenses - kebutuhan dasar
  static const List<String> essentialCategories = [
    rent,
    household,
    transportation,
    insurance,
    incomeTax,
    propertyTax,
    healthcare,
    education,
  ];

  /// Optional expenses - bisa dikurangi
  static const List<String> optionalCategories = [
    personalPleasure,
    familyRecreation,
    gifts,
    maintenance,
    householdStaff,
    membership,
    socialContribution,
    other,
  ];

  static const List<String> values = [
    ...essentialCategories,
    ...optionalCategories,
  ];

  /// Indonesian labels for display
  static String nameId(String category) {
    switch (category) {
      case rent: return 'Sewa / Angsuran';
      case household: return 'Biaya Rumah Tangga';
      case transportation: return 'Biaya Transport';
      case insurance: return 'Asuransi';
      case incomeTax: return 'Pajak Penghasilan';
      case propertyTax: return 'Pajak Property';
      case personalPleasure: return 'Kesenangan Pribadi';
      case familyRecreation: return 'Rekreasi Keluarga';
      case gifts: return 'Hadiah';
      case education: return 'Pendidikan';
      case maintenance: return 'Perbaikan & Maintenance';
      case householdStaff: return 'Gaji Pegawai RT';
      case membership: return 'Keanggotaan Club';
      case healthcare: return 'Kesehatan';
      case socialContribution: return 'Kontribusi Sosial';
      case other: return 'Lainnya';
      default: return category;
    }
  }
}

/// Transactions table - records all money movements
///
/// Every income and expense is recorded here.
/// Used to calculate burn rate and income sources.
@DataClassName('TransactionEntry')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
