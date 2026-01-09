/*
 * File Name   : favorites_quotes_screen.dart
 * Description : Screen displaying all favorite quotes and recent cached quotes.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quote.dart';
import '../helpers/hive_helper.dart';

class FavoritesQuotesScreen extends StatefulWidget {
  const FavoritesQuotesScreen({super.key});

  @override
  State<FavoritesQuotesScreen> createState() => _FavoritesQuotesScreenState();
}

class _FavoritesQuotesScreenState extends State<FavoritesQuotesScreen> {
  List<Quote> _favoriteQuotes = [];
  List<Quote> _weeklyQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final favorites = await HiveHelper.getFavoriteQuotes();
    final weekly = await HiveHelper.getWeeklyQuotes();

    setState(() {
      _favoriteQuotes = favorites;
      _weeklyQuotes = weekly;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Quote quote) async {
    await HiveHelper.removeFavoriteQuote(quote);
    await _loadFavorites();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites')),
    );
  }

  void _copyQuote(Quote quote) {
    Clipboard.setData(ClipboardData(text: '${quote.text}\n- ${quote.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showEmpty = _favoriteQuotes.isEmpty && _weeklyQuotes.isEmpty;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : showEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_favoriteQuotes.isNotEmpty) ...[
                        Text(
                          'Favorite Quotes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._favoriteQuotes.asMap().entries.map(
                              (entry) => _buildQuoteCard(
                                entry.value,
                                true,
                                entry.key,
                              ),
                            ),
                        const SizedBox(height: 24),
                      ],
                      if (_weeklyQuotes.isNotEmpty) ...[
                        Text(
                          'Recent Quotes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._weeklyQuotes.asMap().entries.map(
                              (entry) => _buildQuoteCard(
                                entry.value,
                                false,
                                entry.key,
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            size: 100,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorite Quotes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mark quotes as favorites to see them here',
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

  Widget _buildQuoteCard(Quote quote, bool isFavorite, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: isFavorite
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: isFavorite
                        ? Colors.white.withOpacity(0.8)
                        : Theme.of(context).colorScheme.primary,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.content_copy,
                          color: isFavorite
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () => _copyQuote(quote),
                      ),
                      if (isFavorite)
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          onPressed: () => _removeFavorite(quote),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                quote.text,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: isFavorite
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '- ${quote.author}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isFavorite
                      ? Colors.white.withOpacity(0.9)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
