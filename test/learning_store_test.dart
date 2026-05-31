import 'package:flutter_test/flutter_test.dart';
import 'package:ki_campus_companion/src/learning_entry.dart';
import 'package:ki_campus_companion/src/learning_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadBookmarkedEntries returns only bookmarks sorted by updatedAt desc', () async {
    final store = LearningStore();

    await store.saveEntry(
      LearningEntry(
        url: 'https://ki-campus.org/a',
        title: 'A',
        note: '',
        status: LearningStatus.open,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 20),
      ),
    );

    await store.saveEntry(
      LearningEntry(
        url: 'https://ki-campus.org/b',
        title: 'B',
        note: '',
        status: LearningStatus.open,
        bookmarked: false,
        updatedAt: DateTime.utc(2026, 5, 21),
      ),
    );

    await store.saveEntry(
      LearningEntry(
        url: 'https://ki-campus.org/c',
        title: 'C',
        note: '',
        status: LearningStatus.open,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final bookmarks = await store.loadBookmarkedEntries();

    expect(bookmarks, hasLength(2));
    expect(bookmarks[0].url, 'https://ki-campus.org/c');
    expect(bookmarks[1].url, 'https://ki-campus.org/a');
  });

  test('ignored web errors are persisted once and can be cleared', () async {
    final store = LearningStore();
    const rule = WebErrorIgnoreRule(
      urlHost: 'matomo.example.org',
      errorCode: -2,
      errorType: 'hostLookup',
      description: 'net::ERR_NAME_NOT_RESOLVED',
      isForMainFrame: false,
    );

    expect(await store.isWebErrorIgnored(rule), isFalse);

    await store.saveIgnoredWebError(rule);
    await store.saveIgnoredWebError(rule);

    final ignoredRules = await store.loadIgnoredWebErrors();
    expect(ignoredRules, hasLength(1));
    expect(ignoredRules.single, rule);
    expect(await store.isWebErrorIgnored(rule), isTrue);

    await store.clearIgnoredWebErrors();

    expect(await store.loadIgnoredWebErrors(), isEmpty);
    expect(await store.isWebErrorIgnored(rule), isFalse);
  });

  test('exportMarkdown contains importable URL scoped JSON payload', () async {
    final store = LearningStore();

    await store.saveEntry(
      LearningEntry(
        url: 'https://ki-campus.org/course/page-21',
        title: 'Seite 21',
        note: 'Importierbare Notiz',
        status: LearningStatus.repeat,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );

    final markdown = await store.exportMarkdown();
    final parsedEntries = LearningExportParser.parse(markdown);

    expect(markdown, contains('```json'));
    expect(markdown, contains('"format": "ki-campus-companion-export"'));
    expect(parsedEntries, hasLength(1));
    expect(parsedEntries.single.url, 'https://ki-campus.org/course/page-21');
    expect(parsedEntries.single.note, 'Importierbare Notiz');
    expect(parsedEntries.single.bookmarked, isTrue);
  });

  test('importMarkdown skips or overwrites identical URLs', () async {
    final store = LearningStore();
    const existingUrl = 'https://ki-campus.org/course/page-21';

    await store.saveEntry(
      LearningEntry(
        url: existingUrl,
        title: 'Alt',
        note: 'Alte Notiz',
        status: LearningStatus.open,
        bookmarked: false,
        updatedAt: DateTime.utc(2026, 5, 20),
      ),
    );

    final markdown = '''
# KI-Campus Companion Export

```json
{
  "format": "ki-campus-companion-export",
  "version": 2,
  "entries": [
    {
      "url": "$existingUrl",
      "title": "Neu",
      "note": "Neue Notiz",
      "status": "repeat",
      "bookmarked": true,
      "updatedAt": "2026-05-24T00:00:00.000Z"
    },
    {
      "url": "https://ki-campus.org/course/page-22",
      "title": "Zusatz",
      "note": "Weitere Notiz",
      "status": "open",
      "bookmarked": true,
      "updatedAt": "2026-05-25T00:00:00.000Z"
    }
  ]
}
```
''';

    final skipResult = await store.importMarkdown(
      markdown,
      clearExisting: false,
      overwriteExisting: false,
    );
    var entries = await store.loadEntries();

    expect(skipResult.imported, 1);
    expect(skipResult.skipped, 1);
    expect(entries[existingUrl]!.note, 'Alte Notiz');
    expect(entries['https://ki-campus.org/course/page-22']!.bookmarked, isTrue);

    final overwriteResult = await store.importMarkdown(
      markdown,
      clearExisting: false,
      overwriteExisting: true,
    );
    entries = await store.loadEntries();

    expect(overwriteResult.imported, 2);
    expect(overwriteResult.overwritten, 2);
    expect(entries[existingUrl]!.note, 'Neue Notiz');
    expect(entries[existingUrl]!.bookmarked, isTrue);
  });

  test('importMarkdown can clear existing entries before import', () async {
    final store = LearningStore();

    await store.saveEntry(
      LearningEntry(
        url: 'https://ki-campus.org/old',
        title: 'Alt',
        note: 'Wird gelöscht',
        status: LearningStatus.open,
        bookmarked: true,
        updatedAt: DateTime.utc(2026, 5, 20),
      ),
    );

    const markdown = '''
## Neu

- URL: <https://ki-campus.org/new>
- Status: Offen
- Bookmark: ja
- Aktualisiert: 2026-05-25T00:00:00.000Z

Neue Notiz
''';

    final result = await store.importMarkdown(
      markdown,
      clearExisting: true,
      overwriteExisting: false,
    );
    final entries = await store.loadEntries();

    expect(result.clearedBeforeImport, isTrue);
    expect(result.imported, 1);
    expect(entries, isNot(contains('https://ki-campus.org/old')));
    expect(entries['https://ki-campus.org/new']!.note, 'Neue Notiz');
    expect(entries['https://ki-campus.org/new']!.bookmarked, isTrue);
  });
}
