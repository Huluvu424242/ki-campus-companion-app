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
}
