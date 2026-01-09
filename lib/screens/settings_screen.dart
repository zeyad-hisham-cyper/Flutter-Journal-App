/*
 * File Name   : settings_screen.dart
 * Description : Settings screen with dark mode toggle, data management, and about section.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import '../helpers/preferences_helper.dart';
import '../helpers/database_helper.dart';
import '../helpers/hive_helper.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _loading = true;

  static const String _appVersion = '1.0.0';
  static const String _developerName = 'Eng. Zeyad Hisham';
  static const String _aboutText =
      'A motivational journal app to help you document your thoughts and stay inspired.';
  static const String _footerText = 'Journal App © 2026 Zeyad Hisham';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final value = await PreferencesHelper.getDarkMode();
    if (!mounted) return;

    setState(() {
      _isDarkMode = value;
      _loading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    await PreferencesHelper.setDarkMode(value);
    widget.onThemeChanged(value);
  }

  Future<void> _clearAllEntries() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all entries'),
        content:
            const Text('This will delete all journal entries permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    await DatabaseHelper.instance.deleteAllEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All entries cleared')),
    );
  }

  Future<void> _clearQuoteCache() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear quote cache'),
        content:
            const Text('This will remove all cached quotes from the device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    await HiveHelper.clearQuoteCache();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote cache cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.colorScheme.surface;
    final divider = onSurface.withOpacity(0.08);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  _SectionTitle(title: 'Appearance'),
                  const SizedBox(height: 10),
                  _CardContainer(
                    child: _SwitchTile(
                      leading: Icons.nightlight_round,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Data Management'),
                  const SizedBox(height: 10),
                  _CardContainer(
                    child: Column(
                      children: [
                        _ActionTile(
                          leading: Icons.playlist_remove,
                          title: 'Clear All Entries',
                          subtitle: 'Delete all journal entries',
                          onTap: _clearAllEntries,
                        ),
                        Divider(height: 1, thickness: 1, color: divider),
                        _ActionTile(
                          leading: Icons.cloud_off,
                          title: 'Clear Quote Cache',
                          subtitle: 'Remove cached quotes',
                          onTap: _clearQuoteCache,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'About'),
                  const SizedBox(height: 10),
                  _CardContainer(
                    child: Column(
                      children: [
                        _InfoTile(
                          leading: Icons.info_outline,
                          title: 'Version',
                          subtitle: _appVersion,
                        ),
                        Divider(height: 1, thickness: 1, color: divider),
                        _InfoTile(
                          leading: Icons.code,
                          title: 'Developer',
                          subtitle: _developerName,
                        ),
                        Divider(height: 1, thickness: 1, color: divider),
                        _InfoTile(
                          leading: Icons.menu_book_outlined,
                          title: 'About Journal App',
                          subtitle: _aboutText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      _footerText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurface.withOpacity(0.45),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.75),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: child,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            leading,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              leading,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            leading,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
