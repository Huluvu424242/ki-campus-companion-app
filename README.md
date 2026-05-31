# KI-Campus Companion App

Eine kleine Flutter-App als **persönliche, lokale Companion-Schicht** für KI-Campus- und Moodle-Lernseiten. Die App ersetzt oder verändert KI-Campus nicht, sondern öffnet Lernseiten in einer WebView und speichert eigene Metadaten pro URL lokal auf dem Gerät.

## Motivation -  Was mir an der KI-Campus Seite nicht gefällt
1. Keine Möglichkeit Bookmarks zu setzen
2. Keine Möglichkeit Notizen anzufertigen
3. Keine Möglichkeit falsche URLs zu korrigieren z.B. verlinkt ein exkurs auf ein englisches Video
   obgleich es das auch in deutsch gibt.
4. Keine Möglichkeit nach Sprache zu filtern, z.B. nur Deutsche Kurse zu finden.
5. Keine Möglichkeit Seiten die zufällig betreten wurden wieder als nicht erledigt zu kennzeichnen.
6. Keine Möglichkeit Fragen an Dozenten oder andere Mitlernende zu stellen
7. Keine Möglichkeit Fragen anderer zu beantworten
8. Keine Möglichkeit Fehler und Erfahrungen mit anderen zu teilen
9. In der Navigation sind die großen Überschriften ohne Ziffern, was die Orientierung erschwert. 
   Man durchläuft dreimal Lektion 1 weil man nicht sieht ob man im Teil 1 oder Teil 2 ist.
10. Es gibt keine Möglichkeit abgeschlossene Kurse zu betreten z.B. um :
    - etwas nachzulesen.
    - das Zertifikat erneut herunterzuladen oder zu teilen
    - einen Exkurs zu wiederholen


## Zielbild und Grenzen

- **Offline-first für Companion-Daten:** Bookmarks, Notizen, Import-/Export-Daten und ignorierte WebView-Fehler liegen lokal in `SharedPreferences`.
- **Keine Moodle-/H5P-Manipulation:** Lernfortschritte auf KI-Campus werden nicht per DOM-Hack oder inoffizieller API verändert.
- **Markdown first:** Exporte werden als Markdown-Datei geteilt und enthalten zusätzlich einen importierbaren JSON-Block.
- **Unterstützte Zielplattformen im Projekt:** Android, Windows und Linux. Für eine echte Web-/GitHub-Pages-Version wäre eine separate Strategie nötig, weil die aktuelle App `dart:io` und native Plugins nutzt.
- **MIT-kompatibel:** Der eigene Projektcode steht unter MIT; Paketlizenzen sind separat dokumentiert.

## Aktueller Funktionsumfang

Beim Start lädt die App `https://ki-campus.org/` und bietet dazu eine lokale Lernnotiz-Schicht:

- **WebView-Navigation**
  - Zurück, Vor, Neu laden
  - Ladefortschritt in der App-Bar
  - aktuelle URL kopieren
  - aktuelle URL manuell bearbeiten und laden
- **Lokale Einträge pro URL**
  - Bookmark an/aus
  - Notiz im Bottom Sheet bearbeiten
  - Seitentitel wird beim Laden gespeichert
  - `updatedAt` wird bei Änderungen aktualisiert
- **Status-Hinweis**
  - Der Button `Nicht Erledigt` setzt aktuell keinen Moodle-Status zurück.
  - Stattdessen erklärt ein Hinweis, dass es kein offizielles Moodle-API für dieses Zurücksetzen gibt.
- **Bookmark-Übersicht**
  - über `Mehr → Bookmarks öffnen`
  - sortiert nach letzter Änderung
  - öffnet Bookmarks direkt wieder in der WebView
- **Markdown-Export und Import**
  - `Mehr → Markdown exportieren` erzeugt eine temporäre `.md`-Datei und öffnet den nativen Teilen-Dialog.
  - `Mehr → Importieren` liest `.md`, `.markdown` oder `.txt` Dateien über den Dateiauswahldialog ein.
  - Beim Import kann vorher alles gelöscht und/oder anhand identischer URLs überschrieben werden.
  - Aktuelle Exporte enthalten einen JSON-Block (`ki-campus-companion-export`, Version 2) plus menschenlesbare Markdown-Abschnitte.
  - Ältere reine Markdown-Exporte werden weiterhin importiert, sofern URL, Status, Bookmark und Aktualisiert-Felder enthalten sind.
- **WebView-Fehlerfilter**
  - WebView-Fehler werden als Banner angezeigt und in die Debug-Ausgabe geschrieben.
  - Details zeigen URL, Fehlercode, Fehlertyp, Haupt-Frame-Info, Beschreibung und Stacktrace.
  - Gleichartige Fehler können dauerhaft ignoriert werden.
  - `Errorfilter reset` löscht die lokale Ignore-Liste.
- **Accessibility-Basics**
  - App-Bar-Aktionen haben Tooltips.
  - Der Fehlerbanner ist semantisch als antippbares Element beschriftet.
  - Fehlerdetails sind als selektierbarer Text zugänglich.

## Projektstruktur

```text
lib/
  main.dart                    # Flutter-Einstiegspunkt
  src/app.dart                 # MaterialApp und Theme
  src/learning_home_page.dart  # WebView, Navigation und UI-Orchestrierung
  src/learning_entry.dart      # URL-gebundenes Datenmodell und Markdown-Ausgabe
  src/learning_store.dart      # Persistenz, Export, Import und Fehlerfilter-Regeln

test/
  learning_entry_test.dart
  learning_store_test.dart
  widget_test.dart

docs/
  ARCHITECTURE.md              # technische Architektur und Datenflüsse
  LICENSE_CHECK.md             # Lizenzhinweise der verwendeten Pakete
  QUALITY_ASSURANCE.md         # Test-, axe- und Mutationstest-Strategie
  accessibility/axe-smoke.html # app-nahe HTML-Oberfläche für axe-Smoke-Checks

.github/workflows/
  flutter.yml                  # Analyse, Tests und Coverage-Artefakt
  accessibility.yml            # axe-Smoke-Check für die app-nahe HTML-Oberfläche
  mutation-tests.yml           # experimentelle, manuell/zeitgesteuert startbare Mutationstests
  android-apk.yml              # einfacher APK-Build als Artifact
  android-release.yml          # signierter Release-Build mit GitHub Release
  security-scan.yml            # Security-Scanner mit privatem GitHub-Security-Advisory bei Findings
```

## Lokal entwickeln

### Voraussetzungen

- Flutter SDK passend zu `pubspec.yaml` (`>=3.5.0 <4.0.0`)
- Android Studio oder Android SDK/Build Tools für Android-Builds
- JDK 17 für den Android-Release-Workflow
- Git
- optional: Linux-/Windows-Desktop-Toolchain, wenn Desktop-Builds lokal getestet werden sollen

### Repository starten

```powershell
git clone https://github.com/Huluvu424242/ki-campus-companion-app.git
cd ki-campus-companion-app
flutter pub get
flutter test
flutter analyze
flutter run
```

Falls Plattformordner in einem lokalen Experiment neu erzeugt werden müssen, zuerst prüfen, ob dadurch projektbezogene Dateien überschrieben würden. Danach:

```powershell
flutter create .
flutter pub get
```

### Android-Hinweise

Die Android-WebView benötigt Netzwerkrechte in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Der Android-Release-Build übernimmt `versionName` und `versionCode` aus der Flutter-Version in `pubspec.yaml`, zum Beispiel `0.2.0+2`.

## Android-Release per GitHub Actions

Für öffentliche APK-Downloads gibt es den manuell startbaren Workflow **Android Release APK** (`.github/workflows/android-release.yml`). Vor dem Start muss die Flutter-Version in `pubspec.yaml` auf eine neue vollständige Version im Format `MAJOR.MINOR.PATCH+BUILD` erhöht werden, z. B. `0.2.0+2`.

### Warum ein stabiler Keystore notwendig ist

Android akzeptiert Updates einer bereits installierten App nur, wenn die neue APK mit demselben Schlüssel signiert ist wie die alte APK. Deshalb darf der Release-Workflow nicht bei jedem Lauf einen neuen Schlüssel erzeugen. Der private Keystore bleibt außerhalb des Repositories und wird GitHub Actions verschlüsselt als Secret bereitgestellt.

Wenn eine schon installierte APK mit einem anderen Schlüssel signiert wurde, kann Android genau dieses Update ablehnen. Dann muss die alte Installation einmalig deinstalliert werden. Danach funktionieren Updates, solange alle zukünftigen APKs mit demselben Keystore signiert werden.

### Keystore lokal mit PowerShell erstellen

> Wichtig: Die folgenden Beispiele sind für **PowerShell** beschrieben. Bitte nicht den Windows-`cmd`-Base64-Weg verwenden.

1. Keystore erzeugen:

```powershell
keytool -genkeypair `
  -v `
  -keystore ki-campus-companion-app-release.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias ki-campus-companion-app
```

2. Keystore als Base64-String für GitHub Actions kodieren:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ki-campus-companion-app-release.jks")) | Set-Clipboard
```

Falls die Ausgabe zusätzlich in eine Datei geschrieben werden soll:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ki-campus-companion-app-release.jks")) | Set-Content -NoNewline "ki-campus-companion-app-release.jks.base64.txt"
```

### GitHub-Secrets einrichten

In GitHub unter **Settings → Secrets and variables → Actions → New repository secret** folgende Secrets anlegen:

- `ANDROID_KEYSTORE_BASE64`: Base64-Inhalt der `.jks`-Datei
- `ANDROID_KEYSTORE_PASSWORD`: Passwort des Keystores
- `ANDROID_KEY_ALIAS`: Alias, z. B. `ki-campus-companion-app`
- `ANDROID_KEY_PASSWORD`: Passwort des Schlüssels

Der Workflow dekodiert den Keystore in `$RUNNER_TEMP`, prüft die Versionskonsistenz, führt `flutter analyze` und `flutter test` aus, baut die Release-APK und veröffentlicht APK plus SHA-256-Prüfsumme als GitHub Release unter `v<release_version>`.

### Release ausführen

1. `pubspec.yaml` auf die neue Version setzen.
2. Änderung mergen.
3. In GitHub **Actions → Android Release APK → Run workflow** öffnen.
4. `release_version` exakt wie in `pubspec.yaml` eintragen.
5. Optional Markdown-Release-Notes erfassen.
6. Workflow starten und das erzeugte Release prüfen.

## Qualitätssicherung

Die QS-Strategie ist in [`docs/QUALITY_ASSURANCE.md`](docs/QUALITY_ASSURANCE.md) dokumentiert. Die reguläre Flutter-CI führt `flutter analyze` und `flutter test --coverage` aus und lädt `coverage/lcov.info` als Artefakt hoch. Zusätzlich prüft der Workflow **Accessibility axe Smoke** eine app-nahe HTML-Oberfläche mit axe. Ein experimenteller Workflow **Mutation Tests** kann manuell oder wöchentlich gestartet werden und ist wegen der aktuellen Flutter-/Tooling-Grenzen nicht blockierend.

## Nützliche Checks für Beiträge

Vor Pull Requests bitte mindestens ausführen:

```powershell
flutter pub get
flutter analyze
flutter test
```

Bei Release-Änderungen zusätzlich prüfen:

```powershell
python scripts/verify_release_version.py --release-version 0.2.0+2 --previous-version 0.1.1+2
```

## Lizenz

Der eigene Projektcode steht unter MIT. Die verwendeten Flutter-Pakete sind gesondert lizenziert; siehe `docs/LICENSE_CHECK.md`.
