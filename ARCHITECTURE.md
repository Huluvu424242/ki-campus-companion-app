# Projekt- und Architekturhinweise

Dieses Dokument enthält die übergeordneten Regeln für Beiträge. Die konkrete technische Architektur der aktuellen Implementierung ist in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) beschrieben.

## Projektprinzipien

- Offlinefähigkeit bevorzugen: lokale Daten dürfen ohne Netz nutzbar bleiben.
- Bookmarks und Notizen lokal speichern.
- WebView logisch kapseln und KI-Campus/Moodle nicht per DOM-Hack manipulieren.
- Accessibility ernst nehmen: beschriftete Aktionen, verständliche Hinweise und bedienbare Dialoge.
- Markdown first: Export/Import bevorzugt menschenlesbare Markdown-Dateien mit maschinenlesbarem JSON-Block.
- MIT-Lizenzkompatibilität beachten.
- Unterstützte Plattformen im Projekt: Windows, Android und Linux.

## Codequalität

- Clean Code beachten.
- Kleine Funktionen bevorzugen.
- Keine Magic Numbers, wenn eine benannte Konstante sinnvoll ist.
- Sprechende Variablen- und Methodennamen verwenden.
- Dateigrößen klein halten und fachliche Funktionalität bei weiterem Wachstum auslagern.
- Feature-basierte, spezialisierte Funktionalität bevorzugen.

## Aktueller Architekturstand

- UI-Einstieg: `lib/main.dart` und `lib/src/app.dart`.
- Hauptscreen: `lib/src/learning_home_page.dart` bündelt WebView, Navigation, Bottom Sheets und UI-Aktionen.
- Datenmodell: `lib/src/learning_entry.dart`.
- Persistenz, Import, Export und Fehlerfilter-Regeln: `lib/src/learning_store.dart`.
- Lokaler Store: `SharedPreferences`.
- Austauschformat: Markdown mit JSON-Block, plus Legacy-Markdown-Import.

## Zielarchitektur bei weiterer Entwicklung

- UI-nahe Ablaufsteuerung weiter aus `LearningHomePage` herauslösen, sobald neue Features hinzukommen.
- Services/Stores nicht direkt tief in Widgets verteilen, sondern pro Feature klar kapseln.
- Repository-/Store-Pattern für Persistenz beibehalten.
- Neue Parser und Services mit Unit-Tests absichern.
- Keine neuen Singleton-Pattern einführen.
- Keine direkten SQL-Strings einführen; aktuell wird keine SQL-Datenbank verwendet.

## Flutter-Konventionen

- Business-Logik möglichst außerhalb von Widgets halten.
- `const` Widgets bevorzugen, wenn möglich.
- Globale Zustände vermeiden.
- Falls ein State-Management-Paket eingeführt wird, sollte dies bewusst und konsistent erfolgen; aktuell nutzt das Projekt kein Riverpod.

## Barrierefreiheit

- Alle Icon-Buttons benötigen Tooltips oder Labels.
- Ausreichende Farbkontraste beachten.
- Dialoge, Bottom Sheets und Fehlerhinweise sollen per Screenreader verständlich sein.
- Tastatur- und Desktop-Bedienung bei Windows/Linux mitdenken.

## Tests

- Neue Services benötigen Unit-Tests.
- Neue Parser oder Formatänderungen benötigen Tests für Erfolg und Fehlerfälle.
- Vor Pull Requests mindestens `flutter analyze` und `flutter test` ausführen.
