# KI-Campus Companion MVP

Ein kleines Flutter-Gerüst für eine **persönliche Lern-Companion-App** um KI-Campus/Moodle-Seiten.

Die App verändert **nicht** den KI-Campus selbst. Sie legt eine eigene lokale Schicht darüber:

- WebView für KI-Campus/Moodle
- Bookmarks pro URL
- Notizen pro URL
- lokaler Lernstatus
- Export als Markdown
- einfache GitHub-Projektstruktur
- MIT-Lizenz für eigenen Code

## Ziel des MVP

Dieses MVP soll beweisen, dass eine persönliche Companion-App sinnvoll sein kann, ohne Moodle/H5P/KI-Campus intern zu manipulieren.

```text
Flutter App
├── WebView: https://ki-campus.org
├── lokale Datenhaltung
│   ├── Bookmarks
│   ├── Notizen
│   └── Lernstatus
└── Overlay / Bottom Sheet
    ├── Notiz bearbeiten
    ├── Bookmark setzen
    ├── Status setzen
    └── Markdown exportieren
```

## Wichtige Grenze

`webview_flutter` unterstützt offiziell Android, iOS und macOS. Für eine echte Web-/GitHub-Pages-Version ist eine andere Strategie nötig, z. B. eine separate Web-App oder iframe-basierte Variante. Dieses Repository ist deshalb zuerst als **Mobile/Desktop-App-Gerüst** gedacht.

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

## GitHub

```cmd
git init
git add .
git commit -m "Initial KI-Campus Companion MVP"
git branch -M main
git remote add origin https://github.com/DEIN_USER/ki-campus-companion.git
git push -u origin main
```

## Lizenz

Der eigene Projektcode steht unter MIT. Die verwendeten Flutter-Pakete sind gesondert lizenziert; siehe `docs/LICENSE_CHECK.md`.
