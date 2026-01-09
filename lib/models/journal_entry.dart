/*
 * File Name   : journal_entry.dart
 * Description : Data model for journal entries with database conversion methods.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

class JournalEntry {
  int? id;
  String title;
  String content;
  String date;
  bool isFavorite;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isFavorite = false,
  });

  /*
   * Convert JournalEntry to Map for database storage
   * Returns: Map containing entry data
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  /*
   * Create JournalEntry from database Map
   * Parameters: map - Database row data
   * Returns: JournalEntry object
   */
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  /*
   * Create a copy of JournalEntry with updated fields
   * Returns: New JournalEntry with modified values
   */
  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? date,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
