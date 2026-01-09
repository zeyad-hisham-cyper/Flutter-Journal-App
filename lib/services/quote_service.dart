/*
 * File Name   : quote_service.dart
 * Description : API service for fetching inspirational quotes with error handling.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';
import '../helpers/hive_helper.dart';
import 'package:intl/intl.dart';

class QuoteService {
  static const String _apiUrl = 'https://zenquotes.io/api/random';

  /*
   * Fetch quote with caching logic
   * First checks cache, then fetches from API if needed
   * Returns: Quote object
   * Throws: Exception if fetch fails and no cache available
   */
  static Future<Quote> fetchQuote() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if we have a cached quote from today
    final isFromToday = await HiveHelper.isQuoteFromToday(currentDate);

    if (isFromToday) {
      final cachedQuote = await HiveHelper.getLastQuote();
      if (cachedQuote != null) {
        return cachedQuote;
      }
    }

    // Try to fetch new quote from API
    try {
      final quote = await _fetchFromApi();

      // Cache the new quote
      await HiveHelper.saveQuote(quote, currentDate);
      await HiveHelper.saveLastOpenDate(currentDate);

      return quote;
    } catch (e) {
      // If API fails, try to get a cached quote from the week
      final cachedQuote = await HiveHelper.getRandomCachedQuote();

      if (cachedQuote != null) {
        return cachedQuote;
      }

      // If no cache available, throw error
      throw Exception('Failed to fetch quote and no cache available');
    }
  }

  /*
   * Fetch quote directly from API
   * Returns: Quote object from API response
   * Throws: Exception if API request fails
   */
  static Future<Quote> _fetchFromApi() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return Quote.fromJson(data[0]);
        }
      }

      throw Exception('API returned status ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /*
   * Force fetch new quote regardless of cache
   * Used for refresh button
   * Returns: Quote object
   * Throws: Exception if fetch fails
   */
  static Future<Quote> refreshQuote() async {
    try {
      final quote = await _fetchFromApi();
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Update cache with new quote
      await HiveHelper.saveQuote(quote, currentDate);

      return quote;
    } catch (e) {
      // If refresh fails, return cached quote or throw
      final cachedQuote = await HiveHelper.getLastQuote();

      if (cachedQuote != null) {
        return cachedQuote;
      }

      throw Exception('Failed to refresh quote: $e');
    }
  }

  /*
   * Get quote for display, prefers cache for performance
   * Returns: Quote object
   */
  static Future<Quote> getQuoteForDisplay() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isFromToday = await HiveHelper.isQuoteFromToday(currentDate);

    if (isFromToday) {
      final cachedQuote = await HiveHelper.getLastQuote();
      if (cachedQuote != null) {
        return cachedQuote;
      }
    }

    return await fetchQuote();
  }
}
