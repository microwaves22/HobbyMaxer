import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared design tokens for HomeSync Figma file `EBU3PSoyzYehUshVKn4APt`,
/// section 03 (Tasks & Chores).
///
/// Values below are copied exactly from the prompt header — do not
/// "improve", paraphrase, or round them. Anything the header does not
/// pin down (radii, spacing, type sizes) is a best-effort default marked
/// with a TODO pointing at the Figma node that must be re-pulled
/// (Teen My To-Do List, node 100:4622, HTTP 429 in the last pass).
abstract final class FigmaColors {
  static const Color ink = Color(0xFF2B3A2B);
  static const Color mute = Color(0xFF7C877A);
  static const Color sage = Color(0xFF5F7F55);
  static const Color sageDark = Color(0xFF4A6A41);
  static const Color sageMid = Color(0xFFA9BE9C);
  static const Color sageLight = Color(0xFFE4EBDC);

  static const Color line = Color(0xFFE8E4D8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFBF7EF);

  // Pastels for task tiles / accents.
  static const Color pastelBlue = Color(0xFFCFE0EE);
  static const Color pastelLavender = Color(0xFFDDD5EE);
  static const Color pastelPeach = Color(0xFFF6D9C4);
  static const Color pastelPink = Color(0xFFF4C9C9);
  static const Color pastelYellow = Color(0xFFFDF0C8);

  /// Kids My To-Do List (node 100:4739) aliases. Same values as the
  /// pastels above, named as the screen spec names them.
  static const Color pink = pastelPink;
  static const Color yellowLight = pastelYellow;

  /// Frosted-card fills: `rgba(255,255,255,0.79)` for cards and
  /// `rgba(255,255,255,0.91)` for inputs and the bottom nav.
  static const Color frostedFill = Color.fromRGBO(255, 255, 255, 0.79);
  static const Color frostedStrong = Color.fromRGBO(255, 255, 255, 0.91);

  /// Rotation for task tiles when Figma gives no per-task color.
  /// TODO(figma 100:4622): replace round-robin with the exact tile
  /// color + glyph mapping from the re-pulled node.
  static const List<Color> tileRotation = [
    pastelBlue,
    pastelLavender,
    pastelPeach,
    pastelPink,
    pastelYellow,
  ];
}

/// Shadows copied exactly from the prompt header.
abstract final class FigmaShadows {
  /// Standard card: `0px 5px 16px -4px rgba(59,77,56,0.07-0.09)`.
  /// Alpha is a range in Figma; 0.08 is the midpoint.
  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(59, 77, 56, 0.08),
    offset: Offset(0, 5),
    blurRadius: 16,
    spreadRadius: -4,
  );

  /// Small: `0px 3px 12px rgba(51,64,38,0.08)`.
  static const BoxShadow small = BoxShadow(
    color: Color.fromRGBO(51, 64, 38, 0.08),
    offset: Offset(0, 3),
    blurRadius: 12,
  );

  /// Primary button: `0px 4px 5px rgba(94,128,84,0.3)`.
  static const BoxShadow primaryButton = BoxShadow(
    color: Color.fromRGBO(94, 128, 84, 0.3),
    offset: Offset(0, 4),
    blurRadius: 5,
  );
}

/// Standard white card: white background, 1px border
/// `rgba(255,255,255,0.95)`, standard card shadow.
abstract final class FigmaCards {
  static BoxDecoration whiteCard({
    // TODO(figma 100:4622): confirm corner radius from the re-pulled
    // node. 16 is a best-effort default, not a Figma value.
    double radius = 16,
  }) {
    return BoxDecoration(
      color: FigmaColors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
        width: 1,
      ),
      boxShadow: const [FigmaShadows.card],
    );
  }
}

/// Nunito type helpers (Medium 500, SemiBold 600, Bold 700, ExtraBold 800).
///
/// Sizes are best-effort defaults: the shared header pins the family and
/// weights but the per-screen sizes live in node 100:4622, which has not
/// been retrieved yet.
abstract final class FigmaType {
  static TextStyle _nunito({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // TODO(figma 100:4622): confirm all sizes/line-heights below.
  static TextStyle screenTitle({Color color = FigmaColors.ink}) => _nunito(
        size: 24,
        weight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle cardTitle({Color color = FigmaColors.ink}) => _nunito(
        size: 16,
        weight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle body({Color color = FigmaColors.mute}) => _nunito(
        size: 14,
        weight: FontWeight.w500,
        color: color,
        height: 1.45,
      );

  static TextStyle label({Color color = FigmaColors.ink}) => _nunito(
        size: 13,
        weight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle points({Color color = FigmaColors.sageDark}) => _nunito(
        size: 13,
        weight: FontWeight.w800,
        color: color,
        height: 1.3,
      );

  static TextStyle button({Color color = FigmaColors.white}) => _nunito(
        size: 16,
        weight: FontWeight.w700,
        color: color,
        height: 1.25,
      );
}
