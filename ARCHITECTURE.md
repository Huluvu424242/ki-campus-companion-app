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

- Clean Code beachten: kleine, fokussierte Funktionen, klare Verantwortlichkeiten, sprechende Namen und geringe Kopplung.
- Keine Magic Numbers oder Magic Strings, wenn eine benannte Konstante bzw. ein typisierter Wert sinnvoll ist.
- Dateigrößen klein halten und fachliche Funktionalität bei weiterem Wachstum in Services, Stores oder Feature-Module auslagern.
- Feature-basierte, spezialisierte Funktionalität bevorzugen.
- Sonar-Empfehlungen als Architekturvorgabe berücksichtigen: Duplikate vermeiden, zyklische Abhängigkeiten verhindern, kognitive Komplexität niedrig halten, Dead Code entfernen und Security Smells ernst nehmen.
- Warnungen aus statischer Analyse nicht pauschal unterdrücken; notwendige Ausnahmen müssen eng begrenzt und begründet sein.

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
- SEO- und Social-Sharing-Anforderungen bei künftigen Web-, Landing-Page- oder Share-Preview-Komponenten architektonisch einplanen, ohne private Companion-Daten unbeabsichtigt zu veröffentlichen.

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
- Perspektivisch soll die CI eine automatische Accessibility-Prüfung mit axe oder einem vergleichbaren Werkzeug fordern; die konkrete Prüfebene ist bei der Umsetzung zu dokumentieren.

## SEO und Social Sharing

- SEO-Regeln sind für alle künftigen Web-/Dokumentations-/Landing-Page-Oberflächen verbindlich mitzudenken: semantische Struktur, sprechende Titel, Meta-Beschreibungen und kanonische URLs.
- Social Sharing soll durch aussagekräftige Share-Titel, Beschreibungen und Vorschau-Metadaten unterstützt werden, sofern die Zielplattform dies erlaubt.
- Native Share-Flows müssen transparent machen, welche lokalen Daten exportiert oder geteilt werden.

## Tests

- Neue Services benötigen Unit-Tests.
- Neue Parser oder Formatänderungen benötigen Tests für Erfolg und Fehlerfälle.
- Zielanforderung: mindestens 90 % Unit-Test-Abdeckung für fachliche Logik, Stores, Parser und Services.
- Mutationstests sollen bereitgestellt werden, falls sie mit Flutter/Dart und der Projektstruktur praktikabel sind; andernfalls ist die Entscheidung nachvollziehbar zu dokumentieren.
- Vor Pull Requests mindestens `flutter analyze` und `flutter test` ausführen.
