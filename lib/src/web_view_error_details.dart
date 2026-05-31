import 'package:webview_flutter/webview_flutter.dart';

import 'web_error_ignore_rule.dart';

class WebViewErrorDetails {
  const WebViewErrorDetails({
    required this.summary,
    required this.fullText,
    required this.ignoreRule,
  });

  factory WebViewErrorDetails.fromError(
    WebResourceError error, {
    required String fallbackUrl,
    required StackTrace stackTrace,
  }) {
    final errorType = error.errorType?.name ?? 'unknown';
    final url = error.url ?? fallbackUrl;
    final urlHost = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    final summary =
        'WebView-Fehler ${error.errorCode} ($errorType): ${error.description}';
    final mainFrame = switch (error.isForMainFrame) {
      true => 'ja',
      false => 'nein',
      null => 'unbekannt',
    };
    final buffer = StringBuffer()
      ..writeln(summary)
      ..writeln()
      ..writeln('URL: $url')
      ..writeln('Fehlercode: ${error.errorCode}')
      ..writeln('Fehlertyp: $errorType')
      ..writeln('Haupt-Frame: $mainFrame')
      ..writeln('Beschreibung: ${error.description}')
      ..writeln()
      ..writeln('Stacktrace:')
      ..write(stackTrace);

    return WebViewErrorDetails(
      summary: summary,
      fullText: buffer.toString(),
      ignoreRule: WebErrorIgnoreRule(
        urlHost: urlHost,
        errorCode: error.errorCode,
        errorType: errorType,
        description: error.description,
        isForMainFrame: error.isForMainFrame,
      ),
    );
  }

  final String summary;
  final String fullText;
  final WebErrorIgnoreRule ignoreRule;
}
