import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/figma_tokens.dart';

/// Vector avatar + crown illustrations for 10 Customization (node 5:248).
///
/// The Figma file ships these as illustrations (cat, fox, bunny, young
/// girl, crown). No Figma exports exist in this repo and the project has
/// no matching avatar components, so these are project-authored flat
/// illustrations drawn with [CustomPaint] — never emoji, stock icons, or
/// hotlinked URLs. When the Figma PNGs land (suggested paths
/// `assets/avatars/<id>.png` and `assets/crown.png`, already covered by
/// the `assets/` bundle entry in pubspec.yaml), swap the painters below
/// for `Image.asset` calls and keep the widget API unchanged.
///
/// All art is drawn in a 0..1 unit space scaled to the requested size,
/// so the same illustration renders at 62px in the main avatar and 28px
/// in the options.

// Art palette. UI chrome still uses FigmaColors; these solids exist only
// inside the illustrations.
const Color _creamFur = Color(0xFFFFFDF7);
const Color _innerEar = Color(0xFFF5A8A8);
const Color _nose = Color(0xFFE87E7E);
const Color _blush = Color.fromRGBO(242, 163, 163, 0.55);
const Color _foxFur = Color(0xFFE8935A);
const Color _foxDark = Color(0xFF5A3B2E);
const Color _skin = Color(0xFFFFDCBE);
const Color _hair = Color(0xFF6B4A35);
const Color _gold = Color(0xFFF0B429);
const Color _goldDark = Color(0xFFD1911F);

/// One of the four avatar illustrations, drawn at [size] square points.
class AvatarArt extends StatelessWidget {
  const AvatarArt({
    super.key,
    required this.avatarId,
    required this.size,
  });

  /// `cat`, `fox`, `bunny`, or `person` (see [avatarOptions]).
  final String avatarId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _AvatarPainter(avatarId),
      ),
    );
  }
}

/// Crown accessory, rendered [height] tall above the main avatar.
class CrownArt extends StatelessWidget {
  const CrownArt({
    super.key,
    this.width = 46,
    this.height = 28,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _CrownPainter(),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.avatarId);

  final String avatarId;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    switch (avatarId) {
      case 'cat':
        _paintCat(canvas, s);
      case 'fox':
        _paintFox(canvas, s);
      case 'bunny':
        _paintBunny(canvas, s);
      case 'person':
        _paintPerson(canvas, s);
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) =>
      oldDelegate.avatarId != avatarId;
}

void _paintEyes(
  Canvas canvas,
  double s, {
  double cy = 0.52,
  double dx = 0.14,
  double r = 0.055,
}) {
  final eye = Paint()..color = FigmaColors.ink;
  final spark = Paint()..color = FigmaColors.white;
  for (final cx in [0.5 - dx, 0.5 + dx]) {
    canvas.drawCircle(Offset(cx * s, cy * s), r * s, eye);
    canvas.drawCircle(
      Offset((cx + 0.018) * s, (cy - 0.018) * s),
      r * 0.35 * s,
      spark,
    );
  }
}

void _paintBlush(
  Canvas canvas,
  double s, {
  double cy = 0.62,
  double dx = 0.22,
}) {
  final blush = Paint()..color = _blush;
  for (final cx in [0.5 - dx, 0.5 + dx]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx * s, cy * s),
        width: 0.11 * s,
        height: 0.07 * s,
      ),
      blush,
    );
  }
}

void _paintSmile(
  Canvas canvas,
  double s, {
  double cy = 0.64,
  double r = 0.075,
}) {
  final mouth = Paint()
    ..color = FigmaColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.022 * s
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromCircle(center: Offset(0.5 * s, cy * s), radius: r * s),
    0.2 * math.pi,
    0.6 * math.pi,
    false,
    mouth,
  );
}

void _paintCat(Canvas canvas, double s) {
  final fur = Paint()..color = _creamFur;
  final inner = Paint()..color = _innerEar;

  Path ear(double x0, double x1, double x2) => Path()
    ..moveTo(x0 * s, 0.44 * s)
    ..lineTo(x1 * s, 0.08 * s)
    ..lineTo(x2 * s, 0.34 * s)
    ..close();
  canvas.drawPath(ear(0.16, 0.30, 0.46), fur);
  canvas.drawPath(ear(0.84, 0.70, 0.54), fur);

  Path innerEar(double x0, double x1, double x2) => Path()
    ..moveTo(x0 * s, 0.36 * s)
    ..lineTo(x1 * s, 0.19 * s)
    ..lineTo(x2 * s, 0.315 * s)
    ..close();
  canvas.drawPath(innerEar(0.235, 0.30, 0.385), inner);
  canvas.drawPath(innerEar(0.765, 0.70, 0.615), inner);

  canvas.drawCircle(Offset(0.5 * s, 0.56 * s), 0.335 * s, fur);

  // Nose + "w" mouth.
  canvas.drawPath(
    Path()
      ..moveTo(0.478 * s, 0.60 * s)
      ..lineTo(0.522 * s, 0.60 * s)
      ..lineTo(0.5 * s, 0.632 * s)
      ..close(),
    Paint()..color = _nose,
  );
  final mouth = Paint()
    ..color = FigmaColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.02 * s
    ..strokeCap = StrokeCap.round;
  for (final cx in [0.483, 0.517]) {
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx * s, 0.63 * s),
        radius: 0.028 * s,
      ),
      0.1 * math.pi,
      0.8 * math.pi,
      false,
      mouth,
    );
  }

  // Whiskers.
  final whisker = Paint()
    ..color = FigmaColors.ink.withValues(alpha: 0.5)
    ..strokeWidth = 0.012 * s
    ..strokeCap = StrokeCap.round;
  for (final mirror in [1.0, -1.0]) {
    for (final y in [0.60, 0.655, 0.71]) {
      final drift = (y - 0.60) * mirror * 0.6;
      canvas.drawLine(
        Offset((0.5 + mirror * 0.20) * s, y * s),
        Offset((0.5 + mirror * (0.40 + drift)) * s, (y + 0.02) * s),
        whisker,
      );
    }
  }

  _paintEyes(canvas, s);
  _paintBlush(canvas, s, cy: 0.615, dx: 0.215);
}

void _paintFox(Canvas canvas, double s) {
  final fur = Paint()..color = _foxFur;
  final dark = Paint()..color = _foxDark;

  canvas.drawPath(
    Path()
      ..moveTo(0.15 * s, 0.42 * s)
      ..lineTo(0.27 * s, 0.05 * s)
      ..lineTo(0.45 * s, 0.31 * s)
      ..close(),
    fur,
  );
  canvas.drawPath(
    Path()
      ..moveTo(0.85 * s, 0.42 * s)
      ..lineTo(0.73 * s, 0.05 * s)
      ..lineTo(0.55 * s, 0.31 * s)
      ..close(),
    fur,
  );
  // Dark ear tips.
  canvas.drawPath(
    Path()
      ..moveTo(0.27 * s, 0.05 * s)
      ..lineTo(0.23 * s, 0.173 * s)
      ..lineTo(0.33 * s, 0.137 * s)
      ..close(),
    dark,
  );
  canvas.drawPath(
    Path()
      ..moveTo(0.73 * s, 0.05 * s)
      ..lineTo(0.77 * s, 0.173 * s)
      ..lineTo(0.67 * s, 0.137 * s)
      ..close(),
    dark,
  );

  canvas.drawCircle(Offset(0.5 * s, 0.57 * s), 0.335 * s, fur);

  // White muzzle.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(0.5 * s, 0.70 * s),
      width: 0.40 * s,
      height: 0.28 * s,
    ),
    Paint()..color = FigmaColors.white,
  );
  // Nose + smile on the muzzle.
  canvas.drawPath(
    Path()
      ..moveTo(0.474 * s, 0.625 * s)
      ..lineTo(0.526 * s, 0.625 * s)
      ..lineTo(0.5 * s, 0.66 * s)
      ..close(),
    dark,
  );
  _paintSmile(canvas, s, cy: 0.665, r: 0.06);

  _paintEyes(canvas, s, cy: 0.50);
  _paintBlush(canvas, s, cy: 0.60, dx: 0.225);
}

void _tiltedOval(
  Canvas canvas,
  double s, {
  required double cx,
  required double cy,
  required double w,
  required double h,
  required double angle,
  required Paint paint,
}) {
  canvas.save();
  canvas.translate(cx * s, cy * s);
  canvas.rotate(angle);
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: w * s,
      height: h * s,
    ),
    paint,
  );
  canvas.restore();
}

void _paintBunny(Canvas canvas, double s) {
  final white = Paint()..color = FigmaColors.white;
  final inner = Paint()..color = _innerEar;

  _tiltedOval(
    canvas,
    s,
    cx: 0.33,
    cy: 0.22,
    w: 0.17,
    h: 0.46,
    angle: -0.18,
    paint: white,
  );
  _tiltedOval(
    canvas,
    s,
    cx: 0.67,
    cy: 0.22,
    w: 0.17,
    h: 0.46,
    angle: 0.18,
    paint: white,
  );
  _tiltedOval(
    canvas,
    s,
    cx: 0.33,
    cy: 0.26,
    w: 0.08,
    h: 0.32,
    angle: -0.18,
    paint: inner,
  );
  _tiltedOval(
    canvas,
    s,
    cx: 0.67,
    cy: 0.26,
    w: 0.08,
    h: 0.32,
    angle: 0.18,
    paint: inner,
  );

  canvas.drawCircle(Offset(0.5 * s, 0.64 * s), 0.29 * s, white);

  // Nose + buck teeth.
  canvas.drawCircle(Offset(0.5 * s, 0.675 * s), 0.022 * s, Paint()
    ..color = _nose);
  final teethBorder = Paint()
    ..color = FigmaColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.014 * s;
  final teethRect = Rect.fromLTRB(
    0.475 * s,
    0.70 * s,
    0.525 * s,
    0.755 * s,
  );
  canvas.drawRect(teethRect, Paint()..color = FigmaColors.white);
  canvas.drawRect(teethRect, teethBorder);
  canvas.drawLine(
    Offset(0.5 * s, 0.70 * s),
    Offset(0.5 * s, 0.755 * s),
    teethBorder,
  );

  _paintEyes(canvas, s, cy: 0.60, dx: 0.125, r: 0.05);
  _paintBlush(canvas, s, cy: 0.66, dx: 0.20);
}

void _paintPerson(Canvas canvas, double s) {
  final hair = Paint()..color = _hair;
  final skin = Paint()..color = _skin;

  // Buns + back hair + face.
  canvas.drawCircle(Offset(0.17 * s, 0.28 * s), 0.105 * s, hair);
  canvas.drawCircle(Offset(0.83 * s, 0.28 * s), 0.105 * s, hair);
  canvas.drawCircle(Offset(0.5 * s, 0.52 * s), 0.375 * s, hair);
  canvas.drawCircle(Offset(0.5 * s, 0.57 * s), 0.295 * s, skin);

  // Fringe with a scalloped edge.
  canvas.drawPath(
    Path()
      ..moveTo(0.21 * s, 0.50 * s)
      ..quadraticBezierTo(0.24 * s, 0.24 * s, 0.5 * s, 0.235 * s)
      ..quadraticBezierTo(0.76 * s, 0.24 * s, 0.79 * s, 0.50 * s)
      ..quadraticBezierTo(0.70 * s, 0.40 * s, 0.62 * s, 0.47 * s)
      ..quadraticBezierTo(0.56 * s, 0.38 * s, 0.50 * s, 0.47 * s)
      ..quadraticBezierTo(0.44 * s, 0.38 * s, 0.38 * s, 0.47 * s)
      ..quadraticBezierTo(0.30 * s, 0.40 * s, 0.21 * s, 0.50 * s)
      ..close(),
    hair,
  );

  // Side locks.
  for (final x0 in [0.175, 0.74]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x0 * s, 0.50 * s, (x0 + 0.085) * s, 0.78 * s),
        Radius.circular(0.04 * s),
      ),
      hair,
    );
  }

  _paintEyes(canvas, s, cy: 0.56, dx: 0.125, r: 0.052);
  _paintSmile(canvas, s, cy: 0.665, r: 0.07);
  _paintBlush(canvas, s, cy: 0.64, dx: 0.20);
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final gold = Paint()..color = _gold;
    final dark = Paint()..color = _goldDark;

    // Spikes.
    canvas.drawPath(
      Path()
        ..moveTo(0.07 * w, 0.62 * h)
        ..lineTo(0.03 * w, 0.16 * h)
        ..lineTo(0.27 * w, 0.42 * h)
        ..lineTo(0.50 * w, 0.06 * h)
        ..lineTo(0.73 * w, 0.42 * h)
        ..lineTo(0.97 * w, 0.16 * h)
        ..lineTo(0.93 * w, 0.62 * h)
        ..close(),
      gold,
    );
    // Tip jewels.
    for (final tip in [
      Offset(0.035 * w, 0.12 * h),
      Offset(0.50 * w, 0.045 * h),
      Offset(0.965 * w, 0.12 * h),
    ]) {
      canvas.drawCircle(tip, 0.045 * w, dark);
    }
    // Base band + gems.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.07 * w, 0.58 * h, 0.93 * w, 0.90 * h),
        Radius.circular(0.06 * h),
      ),
      gold,
    );
    for (final cx in [0.30, 0.50, 0.70]) {
      canvas.drawCircle(Offset(cx * w, 0.74 * h), 0.05 * w, dark);
    }
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) => false;
}
