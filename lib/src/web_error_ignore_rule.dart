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
