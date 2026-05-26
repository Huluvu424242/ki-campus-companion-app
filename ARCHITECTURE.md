# Projektregeln

## Codequalität
- Clean Code beachten
- kleine Funktionen bevorzugen
- keine Magic Numbers
- sprechende Variablennamen

## Architektur
- Feature-first Struktur
- Services nicht direkt aus UI aufrufen
- Repository Pattern verwenden

## Barrierefreiheit
- alle Buttons benötigen Labels
- ausreichende Farbkontraste
- Keyboard-Navigation unterstützen

## Flutter
- kein Business-Logic-Code im Widget
- Riverpod statt globaler States
- bevorzugt const Widgets

## Tests
- neue Services benötigen Unit-Tests
- keine ungetesteten Parser

## Verboten
- keine neuen Singleton-Pattern
- keine direkten SQL-Strings