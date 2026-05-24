import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'learning_entry.dart';

class LearningStore {
  static const _entriesKey = 'learning_entries_v1';

  Future<Map<String, LearningEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw) as Map<String, Object?>;
    return decoded.map(
      (url, value) => MapEntry(
        url,
        LearningEntry.fromJson(value as Map<String, Object?>),
      ),
    );
  }

  Future<void> saveEntry(LearningEntry entry) async {
    final entries = await loadEntries();
    final nextEntry = entry.copyWith(updatedAt: DateTime.now());
    entries[nextEntry.url] = nextEntry;
    await _saveEntries(entries);
  }

  Future<void> deleteEntry(String url) async {
    final entries = await loadEntries();
    entries.remove(url);
    await _saveEntries(entries);
  }

  Future<String> exportMarkdown() async {
    final entries = await loadEntries();
    final sortedEntries = entries.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final body = sortedEntries.map((entry) => entry.toMarkdown()).join('\\n');

    return '''
# KI-Campus Companion Export

Exportiert: ${DateTime.now().toIso8601String()}

$body
''';
  }

  Future<void> _saveEntries(Map<String, LearningEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      entries.map((url, entry) => MapEntry(url, entry.toJson())),
    );
    await prefs.setString(_entriesKey, raw);
  }
}
