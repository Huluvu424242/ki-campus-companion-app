# Architektur

## Leitprinzip

Die KI-Campus Companion App ist eine lokale Companion-Schicht um KI-Campus-/Moodle-Seiten. Sie kapselt die WebView logisch in der UI, speichert eigene Lernmetadaten lokal und vermeidet bewusst Eingriffe in Moodle-/H5P-Daten oder DOM-Hacks.

## Plattformannahmen

- Unterstützte Projektplattformen: Android, Windows und Linux.
- Die App nutzt native Flutter-Plugins und `dart:io`; sie ist daher aktuell keine Flutter-Web-App.
- Android nutzt explizit `AndroidWebViewWidgetCreationParams` mit Hybrid Composition.
- Für Plattformen ohne eingebettete WebView-Unterstützung zeigt die UI eine Fallback-Ansicht mit Hinweis, die Lernseite im Browser zu öffnen.

## Laufzeitbausteine

```text
main.dart
  └─ KiCampusCompanionApp
      └─ LearningHomePage
          ├─ WebViewController / WebViewWidget
          ├─ LearningStore
          └─ LearningEntry
```

### `KiCampusCompanionApp`

- richtet `MaterialApp` ein
- nutzt Material 3 mit blauem Seed-Farbschema
- startet direkt mit `LearningHomePage`

### `LearningHomePage`

`LearningHomePage` ist aktuell die UI-Orchestrierung des MVP:

- initialisiert die WebView mit `https://ki-campus.org/`
- aktiviert JavaScript für Moodle/KI-Campus-Seiten
- verwaltet aktuellen URL- und Titel-Kontext
- verarbeitet WebView-Navigation, Ladefortschritt und Fehler
- bietet App-Bar-Aktionen für Zurück, Vor, Neu laden, URL kopieren und URL bearbeiten
- bietet Bottom-Navigation für Bookmark, Notiz, Nicht-Erledigt-Hinweis, Fehlerfilter-Reset und Mehr-Menü
- öffnet Bottom Sheets für Notizen, Bookmarks und Mehr-Aktionen
- ruft für Persistenz, Export, Import und Fehlerfilter den `LearningStore` auf

Die Klasse enthält noch UI-nahe Ablaufsteuerung. Business-Logik, die Persistenz oder Import-/Export-Parsing betrifft, liegt bereits im Store bzw. Parser.

### `LearningEntry`

`LearningEntry` ist das URL-gebundene Datenmodell:

```text
url         # Primärschlüssel im lokalen Store
title       # zuletzt bekannter Seitentitel
note        # lokale Freitextnotiz
status      # lokaler Statuswert
bookmarked  # lokales Bookmark-Flag
updatedAt   # letzte lokale Aktualisierung
```

Statuswerte im Modell:

- `open` → `Offen`
- `understood` → `Verstanden`
- `repeat` → `Nicht Erledigt`
- `done` → `Erledigt`

Aktueller UI-Stand: Die Bottom-Navigation setzt nicht alle Statuswerte aktiv. Der sichtbare `Nicht Erledigt`-Button informiert nur darüber, dass ein Zurücksetzen des Moodle-Erledigt-Status ohne offizielles API nicht implementiert ist.

### `LearningStore`

`LearningStore` kapselt die lokale Persistenz und dateibasierten Austauschformate:

- lädt und speichert alle `LearningEntry`-Objekte in `SharedPreferences` unter `learning_entries_v1`
- speichert Änderungen mit aktualisiertem `updatedAt`
- liefert Bookmarks sortiert nach `updatedAt` absteigend
- exportiert alle Einträge als Markdown
- importiert aktuelle JSON-basierte Markdown-Exporte und ältere reine Markdown-Abschnitte
- speichert ignorierte WebView-Fehlerregeln unter `ignored_web_errors_v1`

## Persistenz

Die App verwendet bewusst lokale Key-Value-Persistenz statt Server-Sync:

- Bookmarks und Notizen bleiben auf dem Gerät.
- Exporte können manuell geteilt oder gesichert werden.
- Importe erlauben eine einfache manuelle Migration auf ein anderes Gerät.
- Es gibt keine automatische Cloud-Synchronisierung und keine KI-Campus-Konto-Integration.

## Markdown-Exportformat

Aktuelle Exporte sind Markdown-Dateien mit zwei Ebenen:

1. ein maschinenlesbarer JSON-Codeblock
2. menschenlesbare Markdown-Abschnitte pro Eintrag

Der JSON-Block trägt:

```json
{
  "format": "ki-campus-companion-export",
  "version": 2,
  "exportedAt": "...",
  "entries": []
}
```

Der Parser bevorzugt den JSON-Block. Wenn kein passender JSON-Block vorhanden ist, versucht er den Legacy-Markdown-Import über Abschnitte mit Feldern wie `URL`, `Status`, `Bookmark` und `Aktualisiert`.

## WebView-Fehlerbehandlung

WebView-Fehler werden in `_WebViewErrorDetails` normalisiert:

- kurze Zusammenfassung für den Banner
- vollständige Details mit URL, Fehlercode, Fehlertyp, Haupt-Frame-Info, Beschreibung und Stacktrace
- `WebErrorIgnoreRule` als stabile Regel zum Ignorieren gleichartiger Fehler

Ignorierte Fehler werden lokal gespeichert und können über `Errorfilter reset` gelöscht werden.

## Import-/Export-Fluss

### Export

1. `LearningHomePage` ruft `LearningStore.exportMarkdown()` auf.
2. Die Markdown-Datei wird temporär als `ki-campus-companion-export.md` geschrieben.
3. `share_plus` öffnet den nativen Teilen-Dialog.

### Import

1. Die UI fragt, ob vorhandene Daten vorher gelöscht werden sollen.
2. Die UI fragt, ob identische URLs überschrieben werden sollen.
3. `file_picker` wählt `.md`, `.markdown` oder `.txt` aus.
4. `LearningStore.importMarkdown()` parst und speichert die Einträge.
5. Die UI zeigt importierte, überschriebene und übersprungene Einträge als SnackBar.

## Release-Architektur Android

Der Android-Release-Workflow nutzt einen stabilen Keystore aus GitHub-Actions-Secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

`android/app/build.gradle.kts` liest diese Werte aus Gradle-Properties oder Umgebungsvariablen. Wenn alle Werte vorhanden sind, wird die Release-Signing-Config verwendet. Lokale Release-Builds fallen ohne diese Werte auf Debug-Signing zurück; der GitHub-Release-Workflow erzwingt die Secrets vor dem Build.

## Tests

Aktuell existieren Tests für:

- Markdown-Ausgabe von `LearningEntry`
- Bookmark-Sortierung
- Persistenz und Reset ignorierter WebView-Fehler
- JSON-basierten Markdown-Export
- Import mit Überspringen, Überschreiben und vorherigem Löschen
- Widget-Smoke-Test

## Bekannte technische Schulden und nächste Schritte

- `LearningHomePage` bündelt noch viel UI-Ablaufsteuerung; mittelfristig können Controller/Services weiter ausgelagert werden.
- Die Statuswerte sind im Datenmodell vorhanden, aber UI-seitig noch nicht vollständig als lokaler Lernstatus bedienbar.
- Eine Suche in Notizen und Bookmarks fehlt noch.
- Automatischer Sync ist bewusst nicht vorhanden; manueller Markdown-Export/-Import ist der aktuelle Austauschmechanismus.
- Für Flutter Web wäre eine separate Implementierung ohne native WebView- und `dart:io`-Abhängigkeiten nötig.
