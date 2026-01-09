/*
 * File Name   : add_edit_entry_screen.dart
 * Description : Screen for creating and editing journal entries with login authentication.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../models/user.dart';
import '../helpers/database_helper.dart';
import '../widgets/login_dialog.dart';

class AddEditEntryScreen extends StatefulWidget {
  const AddEditEntryScreen({super.key});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isEditMode = false;
  JournalEntry? _existingEntry;
  User? _currentUser;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we're editing an existing entry
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is JournalEntry && !_isEditMode) {
      _existingEntry = args;
      _isEditMode = true;
      _titleController.text = args.title;
      _contentController.text = args.content;
      _selectedDate = DateTime.parse(args.date);
    }
  }

  /*
   * Show login dialog when screen loads for new entries
   */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditMode) {
        _showLoginDialog();
      }
    });
  }

  /*
   * Show login/register dialog
   */
  Future<void> _showLoginDialog() async {
    final user = await showDialog<User>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoginDialog(),
    );

    if (user != null) {
      setState(() => _currentUser = user);
    } else {
      // User cancelled login, go back
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /*
   * Show date picker dialog
   */
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /*
   * Validate and save journal entry
   */
  Future<void> _saveEntry() async {
    // Check authentication for new entries
    if (!_isEditMode && _currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to create an entry'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final entry = JournalEntry(
        id: _existingEntry?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        isFavorite: _existingEntry?.isFavorite ?? false,
      );

      try {
        if (_isEditMode) {
          await DatabaseHelper.instance.updateEntry(entry);
        } else {
          await DatabaseHelper.instance.insertEntry(entry);
        }

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Entry updated successfully'
                    : 'Entry created successfully',
              ),
            ),
          );
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save entry. Please try again.'),
            ),
          );
        }
      }
    }
  }

  /*
   * Confirm and cancel entry creation/editing
   */
  Future<void> _cancelEntry() async {
    final hasChanges =
        _titleController.text.isNotEmpty || _contentController.text.isNotEmpty;

    if (!hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Are you sure you want to discard your changes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Entry' : 'New Entry'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelEntry,
        ),
        actions: [
          if (_currentUser != null || _isEditMode)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveEntry,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info (for new entries)
            if (!_isEditMode && _currentUser != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          _currentUser!.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _currentUser!.email,
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
                      ),
                      TextButton(
                        onPressed: _showLoginDialog,
                        child: const Text('Switch'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isEditMode && _currentUser != null)
              const SizedBox(height: 16),

            // Title Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a title for your entry',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.title),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectDate(context),
              ),
            ),

            const SizedBox(height: 16),

            // Content Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your thoughts here...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                  maxLines: null,
                  minLines: 12,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Word Count
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.text_fields, size: 16),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: _contentController,
                      builder: (context, value, child) {
                        final wordCount = value.text.trim().isEmpty
                            ? 0
                            : value.text.trim().split(RegExp(r'\s+')).length;
                        final charCount = value.text.length;

                        return Text(
                          '$wordCount words, $charCount characters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
