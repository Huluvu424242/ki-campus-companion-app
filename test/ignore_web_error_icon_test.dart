import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ki_campus_companion/src/ignore_web_error_icon.dart';

void main() {
  testWidgets(
    'IgnoreWebErrorIcon follows the surrounding IconTheme',
    (tester) async {
      const iconColor = Color(0xff123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: IconTheme(
            data: IconThemeData(size: 30, color: iconColor),
            child: IgnoreWebErrorIcon(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 30);
      expect(sizedBox.height, 30);
      expect(psstIconAssetPath, 'assets/icons/Psst.svg');

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      final painter = customPaint.painter;
      expect(painter, isA<IgnoreWebErrorIconPainter>());
      final iconPainter = painter as IgnoreWebErrorIconPainter;
      expect(iconPainter.color, iconColor);
    },
  );
}
