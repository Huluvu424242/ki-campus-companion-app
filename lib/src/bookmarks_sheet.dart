import 'package:flutter/material.dart';

import 'learning_entry.dart';

class BookmarksSheet extends StatelessWidget {
  const BookmarksSheet({
    super.key,
    required this.bookmarks,
    required this.onBookmarkSelected,
  });

  final List<LearningEntry> bookmarks;
  final ValueChanged<LearningEntry> onBookmarkSelected;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Noch keine Bookmarks vorhanden.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final entry = bookmarks[index];
        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(entry.title.isEmpty ? entry.url : entry.title),
          subtitle: Text(entry.url),
          onTap: () => onBookmarkSelected(entry),
        );
      },
    );
  }
}
