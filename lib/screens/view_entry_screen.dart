/*
 * File Name   : view_entry_screen.dart
 * Description : Screen for viewing, editing, and deleting individual journal entries.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/journal_entry.dart';
import '../helpers/database_helper.dart';

class ViewEntryScreen extends StatefulWidget {
  const ViewEntryScreen({super.key});

  @override
  State<ViewEntryScreen> createState() => _ViewEntryScreenState();
}

class _ViewEntryScreenState extends State<ViewEntryScreen> {
  JournalEntry? _entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is JournalEntry) {
      setState(() => _entry = args);
    }
  }

  /*
   * Navigate to edit screen
   */
  Future<void> _editEntry() async {
    if (_entry == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/add-entry',
      arguments: _entry,
    );

    if (result == true) {
      // Reload entry data
      final updatedEntry = await DatabaseHelper.instance.getEntry(_entry!.id!);
      if (updatedEntry != null && mounted) {
        setState(() => _entry = updatedEntry);
      }
    }
  }

  /*
   * Delete entry with confirmation
   */
  Future<void> _deleteEntry() async {
    if (_entry == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await DatabaseHelper.instance.deleteEntry(_entry!.id!);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    }
  }

  /*
   * Toggle favorite status
   */
  Future<void> _toggleFavorite() async {
    if (_entry == null) return;

    final updatedEntry = _entry!.copyWith(isFavorite: !_entry!.isFavorite);
    await DatabaseHelper.instance.updateEntry(updatedEntry);

    setState(() => _entry = updatedEntry);

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
   * Share entry (placeholder for future implementation)
   */
  void _shareEntry() {
    if (_entry == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Entry not found'),
        ),
      );
    }

    final formattedDate = DateFormat('MMMM dd, yyyy').format(
      DateTime.parse(_entry!.date),
    );

    final wordCount = _entry!.content.trim().split(RegExp(r'\s+')).length;
    final readTime = (wordCount / 200).ceil();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _entry!.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _entry!.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareEntry,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editEntry();
              } else if (value == 'delete') {
                _deleteEntry();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entry!.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$readTime min read',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entry!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Metadata Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetadataItem(
                                Icons.text_fields,
                                '$wordCount words',
                              ),
                              _buildMetadataItem(
                                Icons.format_size,
                                '${_entry!.content.length} characters',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),

      // Action Buttons
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteEntry,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editEntry,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
    );
  }

  /*
   * Build metadata item widget
   */
  Widget _buildMetadataItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
