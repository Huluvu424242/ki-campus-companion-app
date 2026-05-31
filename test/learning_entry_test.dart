import 'package:flutter_test/flutter_test.dart';
import 'package:ki_campus_companion/src/learning_entry.dart';

void main() {
  test('LearningEntry exports markdown', () {
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
  });
}
