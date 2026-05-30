import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'learning_entry.dart';

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

    final body = sortedEntries.map((entry) => entry.toMarkdown()).join('\\n');

    return '''
# KI-Campus Companion Export

Exportiert: ${DateTime.now().toIso8601String()}

$body
''';
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
