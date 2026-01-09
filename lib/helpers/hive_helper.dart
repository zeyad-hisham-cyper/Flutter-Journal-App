/*
 * File Name   : hive_helper.dart
 * Description : Hive storage manager for caching quotes and app data.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';

class HiveHelper {
  static const String _quotesBox = 'quotes';
  static const String _settingsBox = 'settings';

  static const String _keyLastQuote = 'lastQuote';
  static const String _keyLastQuoteDate = 'lastQuoteDate';
  static const String _keyWeeklyQuotes = 'weeklyQuotes';

  static const String _keyFavoriteQuotes = 'favoriteQuotes';
  static const String _legacyKeyFavoriteQuote = 'favoriteQuote';

  static String _quoteIdentity(Quote quote) {
    return '${quote.text}||${quote.author}';
  }

  static Future<void> _migrateLegacyFavoriteIfNeeded(Box box) async {
    final favorites = box.get(_keyFavoriteQuotes, defaultValue: []);
    final legacy = box.get(_legacyKeyFavoriteQuote);

    final hasFavorites = favorites is List && favorites.isNotEmpty;
    final hasLegacy = legacy != null;

    if (hasFavorites || !hasLegacy) return;

    final legacyMap = Map<String, dynamic>.from(legacy);
    final legacyQuote = Quote.fromStoredJson(legacyMap);
    legacyQuote.isFavorite = true;

    final migrated = <dynamic>[
      {
        'id': _quoteIdentity(legacyQuote),
        'quote': legacyQuote.toJson(),
      },
    ];

    await box.put(_keyFavoriteQuotes, migrated);
    await box.delete(_legacyKeyFavoriteQuote);
  }

  /*
   * Save quote with date stamp for daily tracking
   * Parameters: quote - Quote object to cache, date - Date string for tracking
   */
  static Future<void> saveQuote(Quote quote, String date) async {
    final box = await Hive.openBox(_quotesBox);

    await box.put(_keyLastQuote, quote.toJson());
    await box.put(_keyLastQuoteDate, date);

    List<dynamic> weeklyQuotes = box.get(_keyWeeklyQuotes, defaultValue: []);
    weeklyQuotes.add({'quote': quote.toJson(), 'date': date});

    if (weeklyQuotes.length > 7) {
      weeklyQuotes = weeklyQuotes.sublist(weeklyQuotes.length - 7);
    }

    await box.put(_keyWeeklyQuotes, weeklyQuotes);
  }

  /*
   * Get cached quote for today
   * Returns: Quote object or null if not cached
   */
  static Future<Quote?> getLastQuote() async {
    final box = await Hive.openBox(_quotesBox);
    final quoteData = box.get(_keyLastQuote);

    if (quoteData != null) {
      return Quote.fromStoredJson(Map<String, dynamic>.from(quoteData));
    }
    return null;
  }

  /*
   * Get date of last cached quote
   * Returns: Date string or empty string if no quote cached
   */
  static Future<String> getLastQuoteDate() async {
    final box = await Hive.openBox(_quotesBox);
    return box.get(_keyLastQuoteDate, defaultValue: '');
  }

  /*
   * Check if cached quote is from today
   * Parameters: currentDate - Today's date string (YYYY-MM-DD)
   * Returns: Boolean indicating if quote is current
   */
  static Future<bool> isQuoteFromToday(String currentDate) async {
    final lastDate = await getLastQuoteDate();
    return lastDate == currentDate;
  }

  /*
   * Get weekly cached quotes for offline mode
   * Returns: List of Quote objects from the past week
   */
  static Future<List<Quote>> getWeeklyQuotes() async {
    final box = await Hive.openBox(_quotesBox);
    List<dynamic> weeklyQuotes = box.get(_keyWeeklyQuotes, defaultValue: []);

    return weeklyQuotes.map((item) {
      final quoteData = Map<String, dynamic>.from(item['quote']);
      return Quote.fromStoredJson(quoteData);
    }).toList();
  }

  /*
   * Get random quote from weekly cache for offline mode
   * Returns: Quote object or null if cache is empty
   */
  static Future<Quote?> getRandomCachedQuote() async {
    final weeklyQuotes = await getWeeklyQuotes();
    if (weeklyQuotes.isEmpty) return null;

    final randomIndex = DateTime.now().millisecond % weeklyQuotes.length;
    return weeklyQuotes[randomIndex];
  }

  /*
   * Save last app open date
   * Parameters: date - Date string
   */
  static Future<void> saveLastOpenDate(String date) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put('lastOpenDate', date);
  }

  /*
   * Get last app open date
   * Returns: Date string or empty string if first launch
   */
  static Future<String> getLastOpenDate() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get('lastOpenDate', defaultValue: '');
  }

  /*
   * Get all favorite quotes
   * Returns: List of Quote objects
   */
  static Future<List<Quote>> getFavoriteQuotes() async {
    final box = await Hive.openBox(_quotesBox);
    await _migrateLegacyFavoriteIfNeeded(box);

    final raw = box.get(_keyFavoriteQuotes, defaultValue: []);
    if (raw is! List) return [];

    final quotes = <Quote>[];
    for (final item in raw) {
      if (item is Map) {
        final quoteMap = Map<String, dynamic>.from(item['quote']);
        final q = Quote.fromStoredJson(quoteMap);
        q.isFavorite = true;
        quotes.add(q);
      }
    }
    return quotes;
  }

  /*
   * Check if a quote is favorited
   * Parameters: quote - Quote to check
   * Returns: true if favorited
   */
  static Future<bool> isQuoteFavorited(Quote quote) async {
    final box = await Hive.openBox(_quotesBox);
    await _migrateLegacyFavoriteIfNeeded(box);

    final raw = box.get(_keyFavoriteQuotes, defaultValue: []);
    if (raw is! List) return false;

    final id = _quoteIdentity(quote);
    return raw.any((item) => item is Map && item['id'] == id);
  }

  /*
   * Add quote to favorites (no duplicates)
   * Parameters: quote - Quote to add
   */
  static Future<void> addFavoriteQuote(Quote quote) async {
    final box = await Hive.openBox(_quotesBox);
    await _migrateLegacyFavoriteIfNeeded(box);

    final raw = box.get(_keyFavoriteQuotes, defaultValue: []);
    final favorites = (raw is List) ? List<dynamic>.from(raw) : <dynamic>[];

    final id = _quoteIdentity(quote);
    final exists = favorites.any((item) => item is Map && item['id'] == id);
    if (exists) return;

    final stored = Quote(text: quote.text, author: quote.author, isFavorite: true);

    favorites.add({
      'id': id,
      'quote': stored.toJson(),
    });

    await box.put(_keyFavoriteQuotes, favorites);
  }

  /*
   * Remove quote from favorites
   * Parameters: quote - Quote to remove
   */
  static Future<void> removeFavoriteQuote(Quote quote) async {
    final box = await Hive.openBox(_quotesBox);
    await _migrateLegacyFavoriteIfNeeded(box);

    final raw = box.get(_keyFavoriteQuotes, defaultValue: []);
    final favorites = (raw is List) ? List<dynamic>.from(raw) : <dynamic>[];

    final id = _quoteIdentity(quote);
    favorites.removeWhere((item) => item is Map && item['id'] == id);

    await box.put(_keyFavoriteQuotes, favorites);
  }

  /*
   * Toggle favorite state for a quote
   * Parameters: quote - Quote to toggle
   * Returns: new favorite state
   */
  static Future<bool> toggleFavoriteQuote(Quote quote) async {
    final isFav = await isQuoteFavorited(quote);
    if (isFav) {
      await removeFavoriteQuote(quote);
      return false;
    } else {
      await addFavoriteQuote(quote);
      return true;
    }
  }

  /*
   * Clear all cached quotes
   */
  static Future<void> clearQuoteCache() async {
    final box = await Hive.openBox(_quotesBox);
    await box.clear();
  }
}
