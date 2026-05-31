import 'package:flutter/material.dart';

class UnsupportedWebViewPlaceholder extends StatelessWidget {
  const UnsupportedWebViewPlaceholder({super.key, required this.startUrl});

  final Uri startUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              'Bitte öffne die Lernseite im Browser:\n${startUrl.toString()}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
