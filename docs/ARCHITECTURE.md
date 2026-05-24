# Architektur

## Prinzip

Die App ist eine lokale Companion-Schicht. Sie greift nicht in Moodle/H5P-Fortschritte ein.

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

## Ausbaustufen

### Phase 1

- WebView
- lokale Notizen
- lokale Bookmarks
- lokale Statusmarker
- Markdown-Export

### Phase 2

- Kursübersicht aus besuchten URLs
- Suche in Notizen
- JSON-Export/Import
- optional Git-Sync über manuelle Dateiablage

### Phase 3

- offizieller API-Zugriff, falls KI-Campus/Moodle sinnvoll möglich
- keine DOM-Hacks als Standardweg
