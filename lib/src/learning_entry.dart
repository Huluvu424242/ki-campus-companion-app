enum LearningStatus {
  open,
  understood,
  repeat,
  done;

  String get label => switch (this) {
        LearningStatus.open => 'Offen',
        LearningStatus.understood => 'Verstanden',
        LearningStatus.repeat => 'Nicht Erledigt',
        LearningStatus.done => 'Erledigt',
      };
}

class LearningEntry {
  const LearningEntry({
    required this.url,
    required this.title,
    required this.note,
    required this.status,
    required this.bookmarked,
    required this.updatedAt,
  });

  final String url;
  final String title;
  final String note;
  final LearningStatus status;
  final bool bookmarked;
  final DateTime updatedAt;

  factory LearningEntry.empty(String url) => LearningEntry(
        url: url,
        title: '',
        note: '',
        status: LearningStatus.open,
        bookmarked: false,
        updatedAt: DateTime.now(),
      );

  LearningEntry copyWith({
    String? url,
    String? title,
    String? note,
    LearningStatus? status,
    bool? bookmarked,
    DateTime? updatedAt,
  }) {
    return LearningEntry(
      url: url ?? this.url,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      bookmarked: bookmarked ?? this.bookmarked,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'url': url,
        'title': title,
        'note': note,
        'status': status.name,
        'bookmarked': bookmarked,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LearningEntry.fromJson(Map<String, Object?> json) {
    return LearningEntry(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      status: LearningStatus.values.byName(
        json['status'] as String? ?? LearningStatus.open.name,
      ),
      bookmarked: json['bookmarked'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String toMarkdown() {
    final safeTitle = title.trim().isEmpty ? url : title.trim();
    final safeNote = note.trim().isEmpty ? '_Keine Notiz._' : note.trim();

    return '''
## $safeTitle

- URL: <$url>
- Status: ${status.label}
- Bookmark: ${bookmarked ? 'ja' : 'nein'}
- Aktualisiert: ${updatedAt.toIso8601String()}

$safeNote
''';
  }
}
