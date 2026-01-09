/*
 * File Name   : favorites_entries_screen.dart
 * Description : Screen displaying all favorite journal entries.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../helpers/database_helper.dart';
import 'package:flutter/foundation.dart';

class FavoritesEntriesScreen extends StatefulWidget {
  final ValueListenable<int> tabIndexListenable;
  final int tabIndex;

  const FavoritesEntriesScreen({
    super.key,
    required this.tabIndexListenable,
    required this.tabIndex,
  });

  @override
  State<FavoritesEntriesScreen> createState() => _FavoritesEntriesScreenState();
}

class _FavoritesEntriesScreenState extends State<FavoritesEntriesScreen> {
  List<JournalEntry> _favoriteEntries = [];
  bool _isLoading = true;

  late final VoidCallback _tabListener;

  @override
  void initState() {
    super.initState();

    _tabListener = () {
      if (widget.tabIndexListenable.value == widget.tabIndex) {
        _loadFavorites();
      }
    };

    widget.tabIndexListenable.addListener(_tabListener);

    _loadFavorites();
  }

  @override
  void dispose() {
    widget.tabIndexListenable.removeListener(_tabListener);
    super.dispose();
  }

  /*
   * Load all favorite entries from database
   */
  Future<void> _loadFavorites() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final entries = await DatabaseHelper.instance.getFavoriteEntries();

    if (!mounted) return;

    setState(() {
      _favoriteEntries = entries;
      _isLoading = false;
    });
  }

  /*
   * Remove entry from favorites
   */
  Future<void> _removeFavorite(JournalEntry entry) async {
    final updatedEntry = entry.copyWith(isFavorite: false);
    await DatabaseHelper.instance.updateEntry(updatedEntry);
    await _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    }
  }

  /*
   * Navigate to view entry
   */
  void _viewEntry(JournalEntry entry) async {
    final result = await Navigator.pushNamed(
      context,
      '/view-entry',
      arguments: entry,
    );

    if (result == true) {
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteEntries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _favoriteEntries[index];
                      return _buildEntryCard(entry, index);
                    },
                  ),
                ),
    );
  }

  /*
   * Build empty state widget
   */
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorite Entries',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mark entries as favorites to see them here',
            style: TextStyle(
              fontSize: 14,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /*
   * Build individual entry card
   */
  Widget _buildEntryCard(JournalEntry entry, int index) {
    final previewLines = entry.content.split('\n').take(2).join('\n');
    final preview = previewLines.length > 100
        ? '${previewLines.substring(0, 100)}...'
        : previewLines;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewEntry(entry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeFavorite(entry),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy')
                        .format(DateTime.parse(entry.date)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                preview,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 400.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
