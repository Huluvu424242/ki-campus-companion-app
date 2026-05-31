# Qualitätssicherung

Dieses Projekt prüft die fachliche Logik und die wichtigsten UI-Leitplanken bewusst offline und reproduzierbar.

## Lokale Pflichtprüfungen

Vor Pull Requests sollen mindestens diese Kommandos laufen, sofern die Entwicklungsumgebung Flutter bereitstellt:

```bash
flutter analyze
flutter test --coverage
```

Die Unit-Tests decken derzeit insbesondere diese fachlichen Bereiche ab:

- `LearningEntry`: Statuslabels, JSON-Roundtrip, Legacy-Defaults und Markdown-Ausgabe.
- `LearningStore`: lokale Persistenz, Bookmark-Sortierung, Löschen, Export/Import, Parser-Fehlerfälle und WebView-Fehlerfilter.
- App-Smoke-Test: instanziiert den Flutter-Root ohne Netzwerkzugriff.

## GitHub Actions

- **Flutter CI** führt Analyse, Tests und Coverage-Erzeugung bei Pushes und Pull Requests aus.
- **Accessibility axe Smoke** prüft eine statische, app-nahe HTML-Smoke-Oberfläche mit `@axe-core/playwright`.
- **Security Scan** führt Semgrep, Trivy, OSV Scanner und OpenSSF Scorecard aus. Erkennt der Workflow Findings, erzeugt er ein draft GitHub Security Advisory statt eines öffentlichen Issues und verlinkt dort das private Report-Artefakt. Für die Advisory-Erstellung sollte das Repository-Secret `SECURITY_ADVISORY_TOKEN` mit der GitHub-Berechtigung „Repository security advisories: write“ gepflegt werden; der Standard-`GITHUB_TOKEN` bleibt nur als Fallback hinterlegt.

Die aktuelle Flutter-App unterstützt Android, Windows und Linux und nutzt native WebView-/Dateisystem-Plugins sowie `dart:io`. Deshalb wird in CI noch keine echte Flutter-Web-Ausgabe über axe geprüft. Die HTML-Smoke-Oberfläche bildet die primären Companion-Bedienelemente nach, damit Kontrast-, Landmark-, Label- und Tastatur-Basics automatisiert regressionssicher bleiben, bis eine dedizierte Web-/Landing-Page oder eine testbare Desktop-A11y-Schicht existiert.

## Mutationstests

Mutationstests sind als eigener, manuell startbarer Workflow **Mutation Tests** eingerichtet. Der Workflow installiert das Dart/Flutter-Mutationstool `mutagen` zur Laufzeit und bricht bewusst nicht hart ab, wenn das Tool mit der aktuellen Flutter-Projektstruktur oder SDK-Version nicht kompatibel ist. Dadurch ist der QS-Status transparent dokumentiert, ohne die reguläre CI wegen eines noch experimentellen Werkzeugs zu blockieren.
