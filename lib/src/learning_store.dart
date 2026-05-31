import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'learning_entry.dart';
import 'learning_export_format.dart';
import 'learning_export_parser.dart';
import 'web_error_ignore_rule.dart';

class LearningStore {
  static const _entriesKey = 'learning_entries_v1';
  static const _ignoredWebErrorsKey = 'ignored_web_errors_v1';

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

  Future<List<LearningEntry>> loadBookmarkedEntries() async {
    final entries = await loadEntries();
    final bookmarks = entries.values.where((entry) => entry.bookmarked).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return bookmarks;
  }

  Future<List<WebErrorIgnoreRule>> loadIgnoredWebErrors() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ignoredWebErrorsKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map(
          (value) => WebErrorIgnoreRule.fromJson(
            value as Map<String, Object?>,
          ),
        )
        .toList(growable: false);
  }

  Future<bool> isWebErrorIgnored(WebErrorIgnoreRule rule) async {
    final rules = await loadIgnoredWebErrors();
    return rules.any((ignoredRule) => ignoredRule == rule);
  }

  Future<void> saveIgnoredWebError(WebErrorIgnoreRule rule) async {
    final rules = await loadIgnoredWebErrors();
    if (rules.any((ignoredRule) => ignoredRule == rule)) {
      return;
    }

    await _saveIgnoredWebErrors([...rules, rule]);
  }

  Future<void> clearIgnoredWebErrors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ignoredWebErrorsKey);
  }

  Future<String> exportMarkdown() async {
    final entries = await loadEntries();
    final sortedEntries = entries.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final exportedAt = DateTime.now().toIso8601String();
    final exportPayload = const JsonEncoder.withIndent('  ').convert({
      'format': LearningExportFormat.name,
      'version': LearningExportFormat.version,
      'exportedAt': exportedAt,
      'entries': sortedEntries.map((entry) => entry.toJson()).toList(),
    });
    final body = sortedEntries.map((entry) => entry.toMarkdown()).join('\n');

    return '''
# KI-Campus Companion Export

Exportiert: $exportedAt

```json
$exportPayload
```

$body
''';
  }

  Future<LearningImportResult> importMarkdown(
    String markdown, {
    required bool clearExisting,
    required bool overwriteExisting,
  }) async {
    final importedEntries = LearningExportParser.parse(markdown);
    if (importedEntries.isEmpty) {
      throw const FormatException(
        'Die Datei enthält keine importierbaren KI-Campus Einträge.',
      );
    }

    final entries =
        clearExisting ? <String, LearningEntry>{} : await loadEntries();
    var importedCount = 0;
    var overwrittenCount = 0;
    var skippedCount = 0;

    for (final entry in importedEntries) {
      final existingEntry = entries[entry.url];
      if (existingEntry != null && !overwriteExisting) {
        skippedCount++;
        continue;
      }

      entries[entry.url] = entry;
      importedCount++;
      if (existingEntry != null) {
        overwrittenCount++;
      }
    }

    await _saveEntries(entries);
    return LearningImportResult(
      imported: importedCount,
      overwritten: overwrittenCount,
      skipped: skippedCount,
      clearedBeforeImport: clearExisting,
    );
  }

  Future<void> _saveIgnoredWebErrors(List<WebErrorIgnoreRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(rules.map((rule) => rule.toJson()).toList());
    await prefs.setString(_ignoredWebErrorsKey, raw);
  }

  Future<void> _saveEntries(Map<String, LearningEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      entries.map((url, entry) => MapEntry(url, entry.toJson())),
    );
    await prefs.setString(_entriesKey, raw);
  }
}
