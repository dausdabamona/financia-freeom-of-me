import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/time_profiles_table.dart';

part 'time_profile_dao.g.dart';

@DriftAccessor(tables: [TimeProfiles])
class TimeProfileDao extends DatabaseAccessor<AppDatabase>
    with _$TimeProfileDaoMixin {
  TimeProfileDao(super.db);

  /// Get all time profiles
  Future<List<TimeProfile>> getAllProfiles() => select(timeProfiles).get();

  /// Get the latest time profile
  Future<TimeProfile?> getLatestProfile() {
    return (select(timeProfiles)
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get time profile by id
  Future<TimeProfile?> getProfileById(int id) {
    return (select(timeProfiles)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a new time profile
  Future<int> insertProfile(TimeProfilesCompanion profile) {
    return into(timeProfiles).insert(profile);
  }

  /// Update a time profile
  Future<bool> updateProfile(TimeProfile profile) {
    return update(timeProfiles).replace(profile);
  }

  /// Insert or update (upsert) the latest profile
  Future<int> upsertProfile(TimeProfilesCompanion profile) {
    return into(timeProfiles).insertOnConflictUpdate(profile);
  }

  /// Delete a time profile
  Future<int> deleteProfile(int id) {
    return (delete(timeProfiles)..where((p) => p.id.equals(id))).go();
  }

  /// Watch the latest time profile
  Stream<TimeProfile?> watchLatestProfile() {
    return (select(timeProfiles)
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
