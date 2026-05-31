import 'package:flutter_test/flutter_test.dart';
import 'package:ki_campus_companion/src/learning_entry.dart';

void main() {
  group('LearningStatus', () {
    test('provides German labels for every persisted status', () {
      expect(
        LearningStatus.values.map((status) => status.label),
        ['Offen', 'Verstanden', 'Nicht Erledigt', 'Erledigt'],
      );
    });
  });

  group('LearningEntry', () {
    test('exports markdown with title, status label and note', () {
      final entry = LearningEntry(
        url: 'https://ki-campus.org/',
        title: 'KI-Campus',
        note: 'Meine Notiz',
        status: LearningStatus.repeat,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 24),
      );

      final markdown = entry.toMarkdown();

      expect(markdown, contains('KI-Campus'));
      expect(markdown, contains('Nicht Erledigt'));
      expect(markdown, contains('Meine Notiz'));
      expect(markdown, contains('- Bookmark: ja'));
    });

    test('exports fallback title and empty-note marker for sparse entries', () {
      final entry = LearningEntry(
        url: 'https://ki-campus.org/course',
        title: '   ',
        note: '   ',
        status: LearningStatus.open,
        bookmarked: false,
        updatedAt: DateTime.utc(2026, 5, 25),
      );

      final markdown = entry.toMarkdown();

      expect(markdown, contains('## https://ki-campus.org/course'));
      expect(markdown, contains('_Keine Notiz._'));
      expect(markdown, contains('- Bookmark: nein'));
    });

    test('serializes and restores all persisted fields', () {
      final entry = LearningEntry(
        url: 'https://ki-campus.org/a',
        title: 'Titel',
        note: 'Notiz',
        status: LearningStatus.understood,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 26, 12, 30),
      );

      final restored = LearningEntry.fromJson(entry.toJson());

      expect(restored.url, entry.url);
      expect(restored.title, entry.title);
      expect(restored.note, entry.note);
      expect(restored.status, entry.status);
      expect(restored.bookmarked, entry.bookmarked);
      expect(restored.updatedAt, entry.updatedAt);
    });

    test('uses safe defaults for optional legacy JSON fields', () {
      final restored = LearningEntry.fromJson({
        'url': 'https://ki-campus.org/legacy',
      });

      expect(restored.title, isEmpty);
      expect(restored.note, isEmpty);
      expect(restored.status, LearningStatus.open);
      expect(restored.bookmarked, isFalse);
    });
  });
}
