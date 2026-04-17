import 'package:flutter/material.dart';
import 'package:in_the_pocket/database/database_migrations.dart';
import 'package:in_the_pocket/services/service_locator.dart';
import 'package:in_the_pocket/ui/listeners/MetronomeClickPlayer.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';

void main() async {
  setupServiceLocator();
  await DatabaseMigrations().migrateDatabase();
  await MetronomeClickPlayer.setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: ApplicationRouter.onGenerateRoute,
        initialRoute: ApplicationRouter.initialRoute,
        routes: ApplicationRouter.routes,
        debugShowCheckedModeBanner: false,
        title: 'In the Pocket',
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0148fe),
            onPrimary: Colors.white,
            primaryContainer: Color(0xFF0148fe),
            onPrimaryContainer: Colors.white,
          ),
        ),
        // Define the dark theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0148fe),
            onPrimary: Colors.white,
            primaryContainer: Color(0xFF0148fe),
            onPrimaryContainer: Colors.white,
          ),
        ),
        // Use the system's theme preference
        themeMode: ThemeMode.system);
  }
}
