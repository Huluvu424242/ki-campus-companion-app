# KI-Campus Companion MVP

Ein kleines Flutter-MVP für eine **persönliche Lern-Companion-App** rund um KI-Campus/Moodle-Seiten.

Die App verändert **nicht** den KI-Campus selbst. Sie legt eine eigene lokale Schicht darüber:

- WebView für KI-Campus/Moodle
- lokale Bookmarks pro URL
- lokale Notizen pro URL
- lokaler Lernstatus pro URL
- Bookmark-Liste mit Direktnavigation
- Markdown-Export über den nativen Teilen-Dialog

## Ziel des MVP

Dieses MVP zeigt, dass eine persönliche Companion-App sinnvoll sein kann, ohne Moodle/H5P/KI-Campus intern zu manipulieren.

## Aktueller Funktionsumfang (Ist-Stand)

- Startseite lädt `https://ki-campus.org/` in einer WebView.
- Top-Bar enthält Navigation (`Zurück`, `Vor`, `Neu laden`) und Ladeindikator.
- Untere Navigation setzt pro aktueller URL:
  - Bookmark an/aus
  - Notiz bearbeiten (Bottom Sheet)
  - Status `Verstanden`
  - Status `Wiederholen`
  - Status `Erledigt`
- Kontextmenü (`⋮`) bietet:
  - Bookmark-Übersicht (sortiert nach letzter Änderung)
  - Markdown-Export aller gespeicherten Einträge
- Datenhaltung lokal in `SharedPreferences`.

## Wichtige Grenze

`webview_flutter` unterstützt offiziell Android, iOS und macOS. Für eine echte Web-/GitHub-Pages-Version ist eine andere Strategie nötig (z. B. separate Web-App).

## Start

```cmd
flutter pub get
flutter run
```

Falls Du aus diesem Gerüst ein vollständiges Flutter-Projekt mit Plattformordnern erzeugen willst:

```cmd
flutter create .
flutter pub get
flutter run
```

## Lizenz

Der eigene Projektcode steht unter MIT. Die verwendeten Flutter-Pakete sind gesondert lizenziert; siehe `docs/LICENSE_CHECK.md`.
