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
}
