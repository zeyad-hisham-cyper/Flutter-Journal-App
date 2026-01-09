/*
 * File Name   : home_screen.dart
 * Description : Main dashboard displaying quote of the day and journal entries list.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../models/quote.dart';
import '../helpers/database_helper.dart';
import '../helpers/hive_helper.dart';
import '../services/quote_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JournalEntry> _entries = [];
  List<JournalEntry> _filteredEntries = [];
  Quote? _currentQuote;
  bool _isLoadingQuote = false;
  bool _isLoadingEntries = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /*
   * Load quote and journal entries on screen initialization
   */
  Future<void> _loadData() async {
    await _loadQuote();
    await _loadEntries();
  }

  /*
   * Fetch and display quote of the day
   */
  Future<void> _loadQuote() async {
    setState(() => _isLoadingQuote = true);

    try {
      final quote = await QuoteService.fetchQuote();
      final isFav = await HiveHelper.isQuoteFavorited(quote);
      quote.isFavorite = isFav;

      setState(() {
        _currentQuote = quote;
        _isLoadingQuote = false;
      });
    } catch (e) {
      setState(() => _isLoadingQuote = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load quote. Check your connection.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /*
   * Refresh quote with new API call
   */
  Future<void> _refreshQuote() async {
    setState(() => _isLoadingQuote = true);

    try {
      final quote = await QuoteService.refreshQuote();
      final isFav = await HiveHelper.isQuoteFavorited(quote);
      quote.isFavorite = isFav;

      setState(() {
        _currentQuote = quote;
        _isLoadingQuote = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote refreshed successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingQuote = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh quote.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /*
   * Load all journal entries from database
   */
  Future<void> _loadEntries() async {
    setState(() => _isLoadingEntries = true);

    final entries = await DatabaseHelper.instance.getEntries();
    setState(() {
      _entries = entries;
      _filteredEntries = entries;
      _isLoadingEntries = false;
    });
  }

  /*
   * Search entries by title or content
   */
  void _searchEntries(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredEntries = _entries);
      return;
    }

    final results = await DatabaseHelper.instance.searchEntries(query);
    setState(() => _filteredEntries = results);
  }

  /*
   * Toggle favorite status for quote
   */
  Future<void> _toggleQuoteFavorite() async {
    if (_currentQuote == null) return;

    final newState = await HiveHelper.toggleFavoriteQuote(_currentQuote!);
    setState(() => _currentQuote!.isFavorite = newState);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newState
              ? 'Quote added to favorites'
              : 'Quote removed from favorites',
        ),
      ),
    );
  }

  /*
   * Toggle favorite status for journal entry
   */
  Future<void> _toggleEntryFavorite(JournalEntry entry) async {
    final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
    await DatabaseHelper.instance.updateEntry(updatedEntry);
    await _loadEntries();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedEntry.isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
        ),
      );
    }
  }

  /*
   * Navigate to entry view
   */
  void _viewEntry(JournalEntry entry) async {
    final result = await Navigator.pushNamed(
      context,
      '/view-entry',
      arguments: entry,
    );

    if (result == true) {
      _loadEntries();
    }
  }

  /*
   * Navigate to add entry screen
   */
  void _addEntry() async {
    final result = await Navigator.pushNamed(context, '/add-entry');

    if (result == true) {
      _loadEntries();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search entries...',
                border: InputBorder.none,
              ),
              onChanged: _searchEntries,
            )
          : const Text('My Journal'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _filteredEntries = _entries;
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshQuote,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadQuote();
        await _loadEntries();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuoteCard(),
          const SizedBox(height: 24),
          _buildEntriesSection(),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    if (_isLoadingQuote) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentQuote == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quote of the Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _currentQuote?.isFavorite == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        _currentQuote?.isFavorite == true ? Colors.red : null,
                  ),
                  onPressed: _toggleQuoteFavorite,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentQuote!.text,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(
              '- ${_currentQuote!.author}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Entries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingEntries)
          const Center(child: CircularProgressIndicator())
        else if (_filteredEntries.isEmpty)
          const Center(child: Text('No journal entries yet.'))
        else
          ..._filteredEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildEntryCard(item, index);
          }),
      ],
    );
  }

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
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleEntryFavorite(entry),
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
