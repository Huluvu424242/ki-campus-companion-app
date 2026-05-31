import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ki_campus_companion/src/import_option_dialog.dart';

void main() {
  Future<bool?> showImportOptionDialog(WidgetTester tester) async {
    return showDialog<bool>(
      context: tester.element(find.byType(TextButton).first),
      builder: (context) => const ImportOptionDialog(
        title: 'Vor Import löschen?',
        message: 'Sollen bestehende Daten gelöscht werden?',
      ),
    );
  }

  testWidgets(
    'ImportOptionDialog offers cancel, no and yes actions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => const ImportOptionDialog(
                        title: 'Vor Import löschen?',
                        message: 'Sollen bestehende Daten gelöscht werden?',
                      ),
                    );
                  },
                  child: const Text('Dialog öffnen'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Dialog öffnen'));
      await tester.pumpAndSettle();

      expect(find.text('Vor Import löschen?'), findsOneWidget);
      expect(
        find.text('Sollen bestehende Daten gelöscht werden?'),
        findsOneWidget,
      );
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Nein'), findsOneWidget);
      expect(find.text('Ja'), findsOneWidget);
    },
  );

  testWidgets(
    'ImportOptionDialog cancel returns null immediately',
    (tester) async {
      bool? result = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ImportOptionDialog(
                        title: 'Vor Import löschen?',
                        message: 'Sollen bestehende Daten gelöscht werden?',
                      ),
                    );
                  },
                  child: const Text('Dialog öffnen'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Dialog öffnen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Vor Import löschen?'), findsNothing);
    },
  );

  testWidgets(
    'ImportOptionDialog returns false or true for no and yes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {},
              child: const Text('Dialog öffnen'),
            ),
          ),
        ),
      );

      var future = showImportOptionDialog(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nein'));
      await tester.pumpAndSettle();
      expect(await future, isFalse);

      future = showImportOptionDialog(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ja'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    },
  );
}
