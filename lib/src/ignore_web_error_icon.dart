import 'package:flutter/material.dart';

const double _psstSvgViewBoxSize = 1024;
const double _psstIconDefaultSize = 24;
const double _psstIconMinStrokeWidth = 1.7;
const String psstIconAssetPath = 'assets/icons/Psst.svg';

/// Renders the [psstIconAssetPath] glyph as a theme-colored icon.
///
/// The source SVG has a white background. For use inside action buttons only
/// the stroked glyph is painted, so it remains readable on error containers and
/// follows the surrounding [IconTheme].
class IgnoreWebErrorIcon extends StatelessWidget {
  const IgnoreWebErrorIcon({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = size ?? iconTheme.size ?? _psstIconDefaultSize;
    final color = iconTheme.color ?? Theme.of(context).colorScheme.onSurface;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: iconSize,
        child: CustomPaint(
          painter: IgnoreWebErrorIconPainter(color),
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
    if (size.isEmpty) {
      return;
    }

    final iconSize = size.shortestSide;
    final iconOffset = Offset(
      (size.width - iconSize) / 2,
      (size.height - iconSize) / 2,
    );
    final scale = iconSize / _psstSvgViewBoxSize;
    final readableStrokeWidth = _psstIconMinStrokeWidth / scale;
    final strokeWidth = readableStrokeWidth > 28.0 ? readableStrokeWidth : 28.0;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(iconOffset.dx, iconOffset.dy);
    canvas.scale(scale);

    canvas.drawCircle(const Offset(512, 512), 474, stroke);
    canvas.drawPath(_buildFacePath(), stroke);
    canvas.drawPath(_buildHandPath(), stroke);

    canvas.restore();
  }

  Path _buildFacePath() {
    return Path()
      ..moveTo(360, 104)
      ..cubicTo(395, 160, 392, 215, 392, 245)
      ..cubicTo(392, 285, 434, 307, 476, 350)
      ..cubicTo(512, 387, 540, 425, 510, 458)
      ..cubicTo(493, 477, 462, 480, 455, 499)
      ..cubicTo(447, 520, 476, 530, 470, 552)
      ..cubicTo(465, 571, 438, 570, 434, 590)
      ..cubicTo(431, 607, 458, 612, 452, 631)
      ..cubicTo(446, 650, 425, 655, 430, 681)
      ..cubicTo(438, 729, 405, 777, 350, 785)
      ..cubicTo(305, 792, 260, 782, 231, 814)
      ..cubicTo(305, 792, 260, 782, 231, 814);
  }

  Path _buildHandPath() {
    return Path()
      ..moveTo(551, 928)
      ..cubicTo(540, 874, 510, 842, 509, 778)
      ..lineTo(523, 464)
      ..cubicTo(525, 426, 578, 425, 579, 465)
      ..lineTo(580, 738)
      ..cubicTo(622, 693, 653, 674, 680, 684)
      ..cubicTo(710, 696, 705, 727, 680, 751)
      ..cubicTo(652, 778, 628, 802, 619, 850)
      ..moveTo(580, 610)
      ..cubicTo(603, 590, 640, 594, 652, 626)
      ..lineTo(652, 740)
      ..moveTo(652, 646)
      ..cubicTo(676, 625, 712, 632, 724, 664)
      ..lineTo(724, 760)
      ..cubicTo(723, 793, 678, 796, 663, 764)
      ..moveTo(724, 674)
      ..cubicTo(746, 653, 782, 661, 792, 691)
      ..lineTo(792, 855);
  }

  @override
  bool shouldRepaint(covariant IgnoreWebErrorIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
