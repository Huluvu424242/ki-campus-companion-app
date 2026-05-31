import 'dart:convert';

import 'learning_entry.dart';
import 'learning_export_format.dart';

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
      if (decoded['format'] != LearningExportFormat.name) {
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
      r'^##\s+(.+?)\s*$([\s\S]*?)(?=^##\s+|(?![\s\S]))',
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
