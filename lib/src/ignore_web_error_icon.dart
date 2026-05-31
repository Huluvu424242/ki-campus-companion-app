import 'package:flutter/material.dart';

class IgnoreWebErrorIcon extends StatelessWidget {
  const IgnoreWebErrorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CustomPaint(
        painter: IgnoreWebErrorIconPainter(
          IconTheme.of(context).color ?? Colors.black,
        ),
      ),
    );
  }
}

class IgnoreWebErrorIconPainter extends CustomPainter {
  const IgnoreWebErrorIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    Offset p(double x, double y) => Offset(x * scaleX, y * scaleY);

    canvas.drawArc(
      Rect.fromCircle(center: p(11, 10), radius: 6 * scaleX),
      -1.55,
      4.85,
      false,
      stroke,
    );
    canvas.drawCircle(p(13.4, 8.4), 0.9 * scaleX, fill);
    canvas.drawPath(
      Path()
        ..moveTo(p(15, 12).dx, p(15, 12).dy)
        ..quadraticBezierTo(
          p(17.4, 13.2).dx,
          p(17.4, 13.2).dy,
          p(14.8, 14.6).dx,
          p(14.8, 14.6).dy,
        ),
      stroke,
    );
    canvas.drawLine(p(7.5, 18), p(15, 18), stroke);

    final fingerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(p(16.5, 7), p(16.5, 19), fingerStroke);
    canvas.drawLine(p(14.7, 11.2), p(19.2, 11.2), stroke);
  }

  @override
  bool shouldRepaint(covariant IgnoreWebErrorIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
