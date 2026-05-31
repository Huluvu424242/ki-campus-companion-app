import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'learning_entry.dart';

class LearningStore {
  static const _entriesKey = 'learning_entries_v1';
  static const _ignoredWebErrorsKey = 'ignored_web_errors_v1';
  static const _exportFormat = 'ki-campus-companion-export';
  static const _exportVersion = 2;

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
      'format': _exportFormat,
      'version': _exportVersion,
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

class LearningImportResult {
  const LearningImportResult({
    required this.imported,
    required this.overwritten,
    required this.skipped,
    required this.clearedBeforeImport,
  });

  final int imported;
  final int overwritten;
  final int skipped;
  final bool clearedBeforeImport;
}

class LearningExportParser {
  static List<LearningEntry> parse(String markdown) {
    final jsonEntries = _parseJsonExport(markdown);
    if (jsonEntries.isNotEmpty) {
      return jsonEntries;
    }

    return _parseLegacyMarkdownExport(markdown);
  }

  static List<LearningEntry> _parseJsonExport(String markdown) {
    final blocks = RegExp(
      r'```json\s*([\s\S]*?)```',
      multiLine: true,
      caseSensitive: false,
    ).allMatches(markdown);

    for (final block in blocks) {
      final Map<String, Object?> decoded;
      try {
        decoded = jsonDecode(block.group(1)!) as Map<String, Object?>;
      } on Object {
        continue;
      }
      if (decoded['format'] != LearningStore._exportFormat) {
        continue;
      }

      final entries = decoded['entries'];
      if (entries is! List<Object?>) {
        throw const FormatException('Der Export enthält keine Eintragsliste.');
      }

      return entries
          .map(
            (value) => LearningEntry.fromJson(value as Map<String, Object?>),
          )
          .where((entry) => entry.url.trim().isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }

  static List<LearningEntry> _parseLegacyMarkdownExport(String markdown) {
    final sections = RegExp(
      r'^##\s+(.+?)\s*$([\s\S]*?)(?=^##\s+|\z)',
      multiLine: true,
    ).allMatches(markdown);

    return sections
        .map(_parseLegacySection)
        .whereType<LearningEntry>()
        .toList(growable: false);
  }

  static LearningEntry? _parseLegacySection(RegExpMatch section) {
    final title = section.group(1)!.trim();
    final content = section.group(2)!;
    final url = _field(content, 'URL')?.replaceAll(RegExp(r'^<|>$'), '').trim();
    if (url == null || url.isEmpty) {
      return null;
    }

    final status = _parseStatus(_field(content, 'Status'));
    final bookmarked = switch (_field(content, 'Bookmark')?.toLowerCase()) {
      'ja' || 'true' => true,
      _ => false,
    };
    final updatedAt = DateTime.tryParse(_field(content, 'Aktualisiert') ?? '') ??
        DateTime.now();
    final note = _noteFromLegacySection(content);

    return LearningEntry(
      url: url,
      title: title == url ? '' : title,
      note: note == '_Keine Notiz._' ? '' : note,
      status: status,
      bookmarked: bookmarked,
      updatedAt: updatedAt,
    );
  }

  static String? _field(String content, String name) {
    final match =
        RegExp('^- $name: (.+)\$', multiLine: true).firstMatch(content);
    return match?.group(1)?.trim();
  }

  static LearningStatus _parseStatus(String? label) {
    final normalizedLabel = label?.trim();
    for (final status in LearningStatus.values) {
      if (status.label == normalizedLabel || status.name == normalizedLabel) {
        return status;
      }
    }

    return LearningStatus.open;
  }

  static String _noteFromLegacySection(String content) {
    final lastBullet =
        RegExp(r'^- .+$', multiLine: true).allMatches(content).lastOrNull;
    if (lastBullet == null) {
      return content.trim();
    }

    return content.substring(lastBullet.end).trim();
  }
}

class WebErrorIgnoreRule {
  const WebErrorIgnoreRule({
    required this.urlHost,
    required this.errorCode,
    required this.errorType,
    required this.description,
    required this.isForMainFrame,
  });

  final String urlHost;
  final int errorCode;
  final String errorType;
  final String description;
  final bool? isForMainFrame;

  factory WebErrorIgnoreRule.fromJson(Map<String, Object?> json) {
    return WebErrorIgnoreRule(
      urlHost: json['urlHost'] as String? ?? '',
      errorCode: json['errorCode'] as int? ?? 0,
      errorType: json['errorType'] as String? ?? 'unknown',
      description: json['description'] as String? ?? '',
      isForMainFrame: json['isForMainFrame'] as bool?,
    );
  }

  Map<String, Object?> toJson() => {
        'urlHost': urlHost,
        'errorCode': errorCode,
        'errorType': errorType,
        'description': description,
        'isForMainFrame': isForMainFrame,
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WebErrorIgnoreRule &&
            other.urlHost == urlHost &&
            other.errorCode == errorCode &&
            other.errorType == errorType &&
            other.description == description &&
            other.isForMainFrame == isForMainFrame;
  }

  @override
  int get hashCode => Object.hash(
        urlHost,
        errorCode,
        errorType,
        description,
        isForMainFrame,
      );
}
