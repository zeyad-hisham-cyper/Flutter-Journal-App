/*
 * File Name   : quote.dart
 * Description : Data model for inspirational quotes with JSON parsing.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

class Quote {
  String text;
  String author;
  bool isFavorite;

  Quote({required this.text, required this.author, this.isFavorite = false});

  /*
   * Create Quote from JSON response
   * Parameters: json - API response data
   * Returns: Quote object
   */
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? json['text'] ?? 'Stay motivated!',
      author: json['a'] ?? json['author'] ?? 'Unknown',
    );
  }

  /*
   * Convert Quote to JSON for storage
   * Returns: Map containing quote data
   */
  Map<String, dynamic> toJson() {
    return {'text': text, 'author': author, 'isFavorite': isFavorite};
  }

  /*
   * Create Quote from stored JSON with favorite status
   * Parameters: json - Stored quote data
   * Returns: Quote object with favorite status
   */
  factory Quote.fromStoredJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] ?? 'Stay motivated!',
      author: json['author'] ?? 'Unknown',
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
