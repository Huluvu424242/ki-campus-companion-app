# KI Campus Companion Regeln

Diese Vorgaben gelten für KI-Agenten und menschliche Beiträge im gesamten Repository. Sie beschreiben Zielanforderungen und Qualitätsleitplanken; noch nicht umgesetzte Punkte dürfen nicht stillschweigend als implementiert dargestellt werden.

## Produkt- und Plattformprinzipien

- Offlinefähigkeit bevorzugen: Companion-Daten müssen auch ohne Netzwerk nutzbar bleiben.
- Bookmarks, Notizen und Fehlerfilter-Regeln lokal speichern; kein versteckter Cloud-Sync.
- WebView logisch kapseln und KI-Campus/Moodle nicht per DOM-Hack oder inoffizieller API manipulieren.
- Accessibility ernst nehmen: bedienbare Tastatur-/Screenreader-Flows, verständliche Labels, semantische Hinweise und ausreichende Kontraste.
- Markdown first: Import/Export bevorzugt menschenlesbare Markdown-Dateien mit maschinenlesbarem JSON-Block.
- MIT Lizenz kompatibel bleiben; neue Abhängigkeiten vor Aufnahme auf Lizenz- und Plattformverträglichkeit prüfen.
- Unterstützte Plattformen: Windows, Android, Linux.

## Clean Code und Wartbarkeit

- Clean-Code-Regeln befolgen: kleine, fokussierte Funktionen, sprechende Namen, geringe Kopplung und hohe Kohäsion.
- Fachliche Logik aus Widgets herauslösen, sobald sie mehr als reine UI-Orchestrierung ist.
- Keine Magic Numbers oder Strings, wenn benannte Konstanten bzw. klar typisierte Werte sinnvoll sind.
- Keine unnötigen Singleton- oder globalen Zustandsmuster einführen.
- Fehlerfälle explizit modellieren und nutzerverständlich melden.
- Öffentliche APIs, komplexe Entscheidungen und Architekturgrenzen knapp in Markdown oder Code-Kommentaren dokumentieren.

## Sonar- und statische Analyse-Empfehlungen

- Sonar-Empfehlungen als Qualitätsleitplanke berücksichtigen: Duplikate vermeiden, Komplexität begrenzen, Dead Code entfernen und Sicherheitswarnungen ernst nehmen.
- Änderungen sollen `flutter analyze` ohne neue Warnungen bestehen.
- Potenzielle Security Smells, unvalidierte Eingaben, schwache Kryptografie, harte Secrets und unsichere Pfade vermeiden.
- Warnungen nicht nur unterdrücken; Unterdrückungen müssen begründet und eng begrenzt sein.

## Barrierefreiheit

- Neue UI muss mit Screenreader, Tastatur/Desktop-Bedienung und Touch bedienbar geplant werden.
- Icon-only-Aktionen benötigen Tooltips, Semantics-Labels oder sichtbare Alternativen.
- Dialoge, Bottom Sheets, Banner und Fehlermeldungen müssen verständliche Titel, Rollen und Fokusführung berücksichtigen.
- Farbentscheidungen müssen ausreichende Kontraste wahren und dürfen Informationen nicht ausschließlich über Farbe vermitteln.
- Für CI ist perspektivisch eine automatische Accessibility-Prüfung mit axe bzw. einem vergleichbaren Werkzeug in GitHub Actions vorzusehen; falls Flutter-native Grenzen bestehen, ist die gewählte Prüfebene zu dokumentieren.

## SEO und Social Sharing

- SEO-Anforderungen gelten insbesondere für künftige Web-/Landing-Page-, Dokumentations- oder Share-Preview-Oberflächen.
- Titel, Beschreibungen, semantische Struktur, kanonische URLs und indexierbare Inhalte sollen bewusst gepflegt werden, sobald Web-Inhalte entstehen.
- Social Sharing soll unterstützt werden: geteilte Inhalte benötigen aussagekräftige Titel, Beschreibungen und Vorschau-Metadaten, sofern die Zielplattform dies erlaubt.
- Native Sharing-Flows sollen keine privaten Notizen unbeabsichtigt veröffentlichen; Nutzer müssen erkennen, welche Daten geteilt werden.

## Qualitätssicherung und Tests

- Neue fachliche Logik braucht Unit-Tests; Parser, Persistenz und Import-/Export-Formate benötigen Erfolgs- und Fehlerfalltests.
- Als Zielanforderung gilt mindestens 90 % Unit-Test-Abdeckung für fachliche Logik und Services.
- Vor Pull Requests mindestens `flutter analyze` und `flutter test` ausführen, sofern die Umgebung dies erlaubt.
- Mutationstests sollen bereitgestellt werden, falls sie mit Flutter/Dart und der Projektstruktur praktikabel sind; andernfalls ist die Entscheidung zu dokumentieren.
- Tests müssen deterministisch und offline ausführbar sein, außer ein Test ist ausdrücklich als Integrationstest mit Netzwerkbedarf gekennzeichnet.
