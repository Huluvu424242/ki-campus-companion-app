# Architektur

## Prinzip

Die App ist eine lokale Companion-Schicht. Sie greift nicht in Moodle/H5P-Fortschritte ein.

## Hauptbausteine

- `LearningHomePage`
  - steuert WebView, Navigation und UI-Aktionen
  - verwaltet aktuellen URL-/Titel-Kontext
- `LearningStore`
  - persistiert `LearningEntry`-Daten in `SharedPreferences`
  - erzeugt Markdown-Export
- `LearningEntry`
  - Datenmodell inkl. JSON-Serialisierung und Markdown-Darstellung

## Datenmodell

Ein `LearningEntry` ist an eine URL gebunden:

```text
url
title
note
status
bookmarked
updatedAt
```

Statuswerte:

- `open`
- `understood`
- `repeat`
- `done`

## Interaktionsfluss

1. WebView lädt KI-Campus.
2. Bei Seitenwechsel wird URL/Titel aktualisiert.
3. Nutzer setzt Bookmark/Notiz/Status für die aktuelle URL.
4. Änderungen werden lokal gespeichert und mit `updatedAt` versehen.
5. Optional: Bookmark-Liste öffnen oder Markdown exportieren/teilen.

## Ausbaustufen

### Nächster Schritt

- Kursübersicht aus besuchten URLs
- Suche in Notizen
- JSON-Export/Import
- optional Git-Sync über manuelle Dateiablage

### Später

- offizieller API-Zugriff, falls KI-Campus/Moodle sinnvoll möglich
- keine DOM-Hacks als Standardweg
