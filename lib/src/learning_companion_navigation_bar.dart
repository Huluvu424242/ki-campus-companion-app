import 'package:flutter/material.dart';

import 'learning_entry.dart';

class LearningCompanionNavigationBar extends StatelessWidget {
  const LearningCompanionNavigationBar({
    super.key,
    required this.entry,
    required this.onBookmarkSelected,
    required this.onNoteSelected,
    required this.onNotDoneSelected,
    required this.onResetErrorsSelected,
    required this.onMoreSelected,
  });

  final LearningEntry entry;
  final VoidCallback onBookmarkSelected;
  final VoidCallback onNoteSelected;
  final VoidCallback onNotDoneSelected;
  final VoidCallback onResetErrorsSelected;
  final VoidCallback onMoreSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _statusIndex(entry.status),
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            onBookmarkSelected();
          case 1:
            onNoteSelected();
          case 2:
            onNotDoneSelected();
          case 3:
            onResetErrorsSelected();
          case 4:
            onMoreSelected();
        }
      },
      destinations: [
        NavigationDestination(
          icon: Icon(
            entry.bookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
          label: 'Merken',
        ),
        const NavigationDestination(
          icon: Icon(Icons.note_alt_outlined),
          label: 'Notiz',
        ),
        const NavigationDestination(
          icon: Icon(Icons.check_box_outline_blank),
          label: 'Nicht Erledigt',
        ),
        const NavigationDestination(
          icon: Icon(Icons.replay),
          label: 'Errorfilter reset',
        ),
        const NavigationDestination(
          icon: Icon(Icons.more_horiz),
          label: 'Mehr',
        ),
      ],
    );
  }

  int _statusIndex(LearningStatus status) {
    return switch (status) {
      LearningStatus.open => 0,
      LearningStatus.understood => 0,
      LearningStatus.repeat => 2,
      LearningStatus.done => 0,
    };
  }
}
