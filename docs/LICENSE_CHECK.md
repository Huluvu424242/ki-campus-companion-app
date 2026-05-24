# Lizenzprüfung MVP

Stand: 2026-05-24

## Ergebnis

Das Projekt kann grundsätzlich unter **MIT-Lizenz** entwickelt werden, solange der eigene Code unter MIT steht und die Lizenzhinweise der Dependencies erhalten bleiben.

## Verwendete Pakete

| Paket | Zweck | Lizenz laut pub.dev | Einschätzung |
|---|---|---|---|
| `webview_flutter` | WebView für KI-Campus/Moodle | BSD-3-Clause | MIT-Projekt kompatibel |
| `shared_preferences` | lokale Key-Value-Speicherung | BSD-3-Clause | MIT-Projekt kompatibel |
| `path_provider` | Speicherpfade für Exportdateien | BSD-3-Clause | MIT-Projekt kompatibel |
| `share_plus` | Teilen/Export über Plattformdialog | BSD-3-Clause | MIT-Projekt kompatibel |
| `flutter_lints` | statische Analyse | BSD-3-Clause | Entwicklungsdependency |

## Hinweise

- BSD-3-Clause ist permissiv und üblicherweise kompatibel mit MIT-lizenziertem Anwendungscode.
- Die MIT-Lizenz gilt nur für den eigenen Code in diesem Repository.
- Flutter SDK, Plattform-SDKs und Drittanbieter-Pakete behalten ihre eigenen Lizenzen.
- Bei späteren Dependencies erneut prüfen, besonders bei UI-Komponenten, Datenbanken, Sync-Frameworks und kommerziellen SDKs.
