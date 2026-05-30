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

Wichtig für Android: Stelle sicher, dass in `android/app/src/main/AndroidManifest.xml` die Netzwerk-Rechte gesetzt sind, sonst lädt die WebView keine Online-Seiten (z. B. Fehler `net::ERR_CACHE_MISS`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Android-Release per GitHub Actions

Für öffentliche APK-Downloads gibt es den manuell startbaren Workflow **Android Release APK**. Vor dem Start muss die Flutter-Version in `pubspec.yaml` auf die neue vollständige Version im Format `MAJOR.MINOR.PATCH+BUILD` erhöht werden, z. B. `0.2.0+2`.

Ablauf:

1. In GitHub **Actions → Android Release APK → Run workflow** öffnen.
2. Als `release_version` exakt die Version aus `pubspec.yaml` eintragen.
3. Optional Markdown-Release-Notes erfassen.

Der Workflow prüft zuerst, dass die angegebene Version noch keinen Release-Tag besitzt, mit `pubspec.yaml` übereinstimmt, größer als der letzte `vMAJOR.MINOR.PATCH+BUILD`-Tag ist und Android weiterhin `versionName`/`versionCode` aus der Flutter-Version übernimmt. Danach werden Analyse, Tests und der Android-Release-Build ausgeführt. Die fertige APK und eine SHA-256-Prüfsumme werden als GitHub Release unter dem Tag `v<release_version>` veröffentlicht.

## Lizenz

Der eigene Projektcode steht unter MIT. Die verwendeten Flutter-Pakete sind gesondert lizenziert; siehe `docs/LICENSE_CHECK.md`.
