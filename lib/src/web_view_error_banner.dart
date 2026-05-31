import 'package:flutter/material.dart';

import 'ignore_web_error_icon.dart';
import 'web_view_error_details.dart';

class WebViewErrorBanner extends StatelessWidget {
  const WebViewErrorBanner({
    super.key,
    required this.error,
    required this.onDismissed,
    required this.onIgnored,
    required this.onShowDetails,
  });

  final WebViewErrorDetails error;
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
                  icon: const IgnoreWebErrorIcon(),
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
