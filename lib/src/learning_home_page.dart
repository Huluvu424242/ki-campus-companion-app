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

  LearningEntry get _currentEntry =>
      _entries[_currentUrl] ?? LearningEntry.empty(_currentUrl);

  @override
  void initState() {
    super.initState();
    _loadEntries();

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
                  debugPrint(details.fullText);
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                    _lastWebError = details;
                  });
                },
              ),
            )
            ..loadRequest(_startUrl);
    }
  }

  Future<void> _loadEntries() async {
    final entries = await _store.loadEntries();
    setState(() => _entries = entries);
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
              Text(_currentTitle, style: Theme.of(context).textTheme.titleMedium),
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
              ? LinearProgressIndicator(value: _progress == 0 ? null : _progress)
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
              await _setStatus(LearningStatus.understood);
            case 3:
              await _setStatus(LearningStatus.repeat);
            case 4:
              await _setStatus(LearningStatus.done);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(entry.bookmarked ? Icons.bookmark : Icons.bookmark_border),
            label: 'Merken',
          ),
          const NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notiz',
          ),
          const NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Verstanden',
          ),
          const NavigationDestination(
            icon: Icon(Icons.replay),
            label: 'Wiederholen',
          ),
          const NavigationDestination(
            icon: Icon(Icons.done_all),
            label: 'Erledigt',
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          switch (value) {
            case 'bookmarks':
              await _openBookmarks();
            case 'export':
              await _exportMarkdown();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'bookmarks',
            child: Text('Bookmarks öffnen'),
          ),
          PopupMenuItem(
            value: 'export',
            child: Text('Markdown exportieren'),
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
      LearningStatus.understood => 2,
      LearningStatus.repeat => 3,
      LearningStatus.done => 4,
    };
  }
}

class _WebViewErrorBanner extends StatelessWidget {
  const _WebViewErrorBanner({
    required this.error,
    required this.onDismissed,
    required this.onShowDetails,
  });

  final _WebViewErrorDetails error;
  final VoidCallback onDismissed;
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
  });

  factory _WebViewErrorDetails.fromError(
    WebResourceError error, {
    required String fallbackUrl,
    required StackTrace stackTrace,
  }) {
    final errorType = error.errorType?.name ?? 'unknown';
    final url = error.url ?? fallbackUrl;
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
    );
  }

  final String summary;
  final String fullText;
}
