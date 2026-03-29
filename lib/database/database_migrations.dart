/// Database migrations get handled here.
/// This is run on startup before the app is loaded.
/// For scripts just impacting incremental development builds, put them here, run, and delete them.
/// For scripts impacting production builds, leave the migration here.
class DatabaseMigrations {
  Future<void> migrateDatabase() async {
    print('[DatabaseMigrations] DB migrations starting...');

    // Migrations will go here.

    print('[DatabaseMigrations] DB migrations complete!');
  }
}
