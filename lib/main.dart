/*
 * File Name   : main.dart
 * Description : Application entry point with routing and theme configuration.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'helpers/preferences_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_edit_entry_screen.dart';
import 'screens/view_entry_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final bool isDarkMode = await PreferencesHelper.getDarkMode();

  runApp(JournalApp(initialDarkMode: isDarkMode));
}

class JournalApp extends StatefulWidget {
  final bool initialDarkMode;

  const JournalApp({super.key, required this.initialDarkMode});

  @override
  State<JournalApp> createState() => _JournalAppState();
}

class _JournalAppState extends State<JournalApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void _handleThemeChanged(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => MainScreen(onThemeChanged: _handleThemeChanged),
        '/add-entry': (context) => const AddEditEntryScreen(),
        '/view-entry': (context) => const ViewEntryScreen(),
        '/settings': (context) =>
            SettingsScreen(onThemeChanged: _handleThemeChanged),
      },
      initialRoute: '/',
    );
  }
}
