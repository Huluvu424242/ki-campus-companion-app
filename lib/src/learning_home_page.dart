import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'learning_entry.dart';
import 'learning_store.dart';

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  static final Uri _startUrl = Uri.parse('https://ki-campus.org/');

  final _store = LearningStore();
  WebViewController? _controller;

  bool get _supportsEmbeddedWebView =>
      Platform.isAndroid || Platform.isWindows || Platform.isLinux;

  String _currentUrl = _startUrl.toString();
  String _currentTitle = 'KI-Campus';
  Map<String, LearningEntry> _entries = {};
  bool _isLoading = true;
  double _progress = 0;
  _WebViewErrorDetails? _lastWebError;
  int _ignoredWebErrorCount = 0;

  LearningEntry get _currentEntry =>
      _entries[_currentUrl] ?? LearningEntry.empty(_currentUrl);

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadIgnoredWebErrorCount();

    if (_supportsEmbeddedWebView) {
      _controller =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (progress) {
                  setState(() => _progress = progress / 100);
                },
                onPageStarted: (url) {
                  setState(() {
                    _isLoading = true;
                    _currentUrl = url;
                    _lastWebError = null;
                  });
                },
                onPageFinished: (url) async {
                  final title = await _controller?.getTitle();
                  setState(() {
                    _isLoading = false;
                    _currentUrl = url;
                    _currentTitle = title ?? url;
                    _lastWebError = null;
                  });
                  await _ensureCurrentEntryTitle();
                },
                onWebResourceError: (error) {
                  final details = _WebViewErrorDetails.fromError(
                    error,
                    fallbackUrl: _currentUrl,
                    stackTrace: StackTrace.current,
                  );
                  unawaited(_handleWebResourceError(details));
                },
              ),
            )
            ..loadRequest(_startUrl);
    }
  }

  Future<void> _loadEntries() async {
    final entries = await _store.loadEntries();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  Future<void> _loadIgnoredWebErrorCount() async {
    final ignoredErrors = await _store.loadIgnoredWebErrors();
    if (!mounted) return;
    setState(() => _ignoredWebErrorCount = ignoredErrors.length);
  }

  Future<void> _handleWebResourceError(_WebViewErrorDetails details) async {
    debugPrint(details.fullText);
    final isIgnored = await _store.isWebErrorIgnored(details.ignoreRule);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _lastWebError = isIgnored ? null : details;
    });
  }

  Future<void> _ensureCurrentEntryTitle() async {
    final entry = _currentEntry;
    if (entry.title == _currentTitle) {
      return;
    }

    await _saveEntry(entry.copyWith(title: _currentTitle));
  }

  Future<void> _saveEntry(LearningEntry entry) async {
    await _store.saveEntry(entry);
    await _loadEntries();
  }

  Future<void> _toggleBookmark() async {
    await _saveEntry(
      _currentEntry.copyWith(
        title: _currentTitle,
        bookmarked: !_currentEntry.bookmarked,
      ),
    );
  }

  Future<void> _setStatus(LearningStatus status) async {
    await _saveEntry(
      _currentEntry.copyWith(
        title: _currentTitle,
        status: status,
      ),
    );
  }

  Future<void> _openNoteSheet() async {
    final noteController = TextEditingController(text: _currentEntry.note);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 5,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notiz zu dieser Seite',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await _saveEntry(
                    _currentEntry.copyWith(
                      title: _currentTitle,
                      note: noteController.text,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
              ),
            ],
          ),
        );
      },
    );

    noteController.dispose();
  }

  Future<void> _exportMarkdown() async {
    final markdown = await _store.exportMarkdown();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ki-campus-companion-export.md');
    await file.writeAsString(markdown);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/markdown')],
      subject: 'KI-Campus Companion Export',
      text: 'Markdown-Export aus der KI-Campus Companion App',
    );
  }

  Future<void> _ignoreWebError(_WebViewErrorDetails error) async {
    await _store.saveIgnoredWebError(error.ignoreRule);
    await _loadIgnoredWebErrorCount();
    if (!mounted) return;
    setState(() => _lastWebError = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Gleichartige WebView-Fehler werden dauerhaft ignoriert.',
        ),
      ),
    );
  }

  Future<void> _resetIgnoredWebErrors() async {
    if (_ignoredWebErrorCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine ignorierten WebView-Fehler vorhanden.'),
        ),
      );
      return;
    }

    await _store.clearIgnoredWebErrors();
    await _loadIgnoredWebErrorCount();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ignorierte WebView-Fehler werden wieder angezeigt.'),
      ),
    );
  }

  Future<void> _showWebErrorDetails(_WebViewErrorDetails error) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline),
          title: const Text('WebView-Fehlerdetails'),
          content: SingleChildScrollView(
            child: SelectableText(error.fullText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openOverflowActions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmarks_outlined),
                title: const Text('Bookmarks öffnen'),
                onTap: () {
                  Navigator.pop(context);
                  _openBookmarks();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload_outlined),
                title: const Text('Markdown exportieren'),
                onTap: () {
                  Navigator.pop(context);
                  _exportMarkdown();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openBookmarks() async {
    final bookmarks = await _store.loadBookmarkedEntries();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
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
              onTap: () {
                Navigator.pop(context);
                _controller?.loadRequest(Uri.parse(entry.url));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _goBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> _goForward() async {
    final controller = _controller;
    if (controller != null && await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _currentEntry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KI-Campus Companion'),
        actions: [
          IconButton(
            tooltip: 'Zurück',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            tooltip: 'Vor',
            onPressed: _goForward,
            icon: const Icon(Icons.arrow_forward),
          ),
          IconButton(
            tooltip: 'Neu laden',
            onPressed: _controller?.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _isLoading
              ? LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                )
              : const SizedBox(height: 3),
        ),
      ),
      body: _supportsEmbeddedWebView
          ? Stack(
              children: [
                _buildWebView(),
                if (_lastWebError case final error?)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _WebViewErrorBanner(
                      error: error,
                      onDismissed: () => setState(() => _lastWebError = null),
                      onIgnored: () => _ignoreWebError(error),
                      onShowDetails: () => _showWebErrorDetails(error),
                    ),
                  ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.desktop_windows, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'In dieser Desktop-Version ist derzeit kein eingebetteter WebView verfügbar.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      'Bitte öffne die Lernseite im Browser:\n${_startUrl.toString()}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _statusIndex(entry.status),
        onDestinationSelected: (index) async {
          switch (index) {
            case 0:
              await _toggleBookmark();
            case 1:
              await _openNoteSheet();
            case 2:
              await _setStatus(LearningStatus.repeat);
            case 3:
              await _resetIgnoredWebErrors();
            case 4:
              await _openOverflowActions();
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
            label: 'Wiederholen',
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
      ),
    );
  }

  Widget _buildWebView() {
    final controller = _controller!;
    if (Platform.isAndroid) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: controller.platform,
          displayWithHybridComposition: true,
        ),
      );
    }

    return WebViewWidget(controller: controller);
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

class _WebViewErrorBanner extends StatelessWidget {
  const _WebViewErrorBanner({
    required this.error,
    required this.onDismissed,
    required this.onIgnored,
    required this.onShowDetails,
  });

  final _WebViewErrorDetails error;
  final VoidCallback onDismissed;
  final VoidCallback onIgnored;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label:
          'WebView-Fehler. Für Details antippen oder mit Schließen ausblenden.',
      child: Card(
        color: colorScheme.errorContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onShowDetails,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Fehlermeldung schließen',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDismissed,
                  icon: const Icon(Icons.close),
                ),
                IconButton(
                  tooltip: 'Gleichartige Fehlermeldungen dauerhaft ignorieren',
                  visualDensity: VisualDensity.compact,
                  onPressed: onIgnored,
                  icon: const _IgnoreWebErrorIcon(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        error.summary,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tippen für vollständige URL und Details.',
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebViewErrorDetails {
  const _WebViewErrorDetails({
    required this.summary,
    required this.fullText,
    required this.ignoreRule,
  });

  factory _WebViewErrorDetails.fromError(
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

    return _WebViewErrorDetails(
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

class _IgnoreWebErrorIcon extends StatelessWidget {
  const _IgnoreWebErrorIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CustomPaint(
        painter: _IgnoreWebErrorIconPainter(
          IconTheme.of(context).color ?? Colors.black,
        ),
      ),
    );
  }
}

class _IgnoreWebErrorIconPainter extends CustomPainter {
  const _IgnoreWebErrorIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    Offset p(double x, double y) => Offset(x * scaleX, y * scaleY);

    canvas.drawArc(
      Rect.fromCircle(center: p(11, 10), radius: 6 * scaleX),
      -1.55,
      4.85,
      false,
      stroke,
    );
    canvas.drawCircle(p(13.4, 8.4), 0.9 * scaleX, fill);
    canvas.drawPath(
      Path()
        ..moveTo(p(15, 12).dx, p(15, 12).dy)
        ..quadraticBezierTo(
          p(17.4, 13.2).dx,
          p(17.4, 13.2).dy,
          p(14.8, 14.6).dx,
          p(14.8, 14.6).dy,
        ),
      stroke,
    );
    canvas.drawLine(p(7.5, 18), p(15, 18), stroke);

    final fingerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(p(16.5, 7), p(16.5, 19), fingerStroke);
    canvas.drawLine(p(14.7, 11.2), p(19.2, 11.2), stroke);
  }

  @override
  bool shouldRepaint(covariant _IgnoreWebErrorIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
