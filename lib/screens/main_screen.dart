/*
 * File Name   : main_screen.dart
 * Description : Main screen with bottom navigation bar for home, favorite entries, and favorite quotes.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_entries_screen.dart';
import 'favorites_quotes_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final ValueNotifier<int> _tabIndexNotifier;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _tabIndexNotifier = ValueNotifier<int>(_currentIndex);

    _screens = [
      HomeScreen(onThemeChanged: widget.onThemeChanged),
      FavoritesEntriesScreen(
        tabIndexListenable: _tabIndexNotifier,
        tabIndex: 1,
      ),
      const FavoritesQuotesScreen(),
    ];
  }

  @override
  void dispose() {
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _tabIndexNotifier.value = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Favorite Entries',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote),
            label: 'Favorite Quotes',
          ),
        ],
      ),
    );
  }
}
