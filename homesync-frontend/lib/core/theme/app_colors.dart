import 'package:flutter/material.dart';

/// HomeSync color palette.
///
/// Light surfaces are clean white/cream with sage-green accents.
/// Dark tones back Teen Mode.
abstract final class AppColors {
  // Light surfaces.
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFF9F8F6);

  // Primary accent.
  static const Color sage = Color(0xFF7A9A85);
  static const Color sageDark = Color(0xFF5C7A65);
  static const Color sageLight = Color(0xFFE4EDE6);

  // Light text.
  static const Color ink = Color(0xFF202624);
  static const Color muted = Color(0xFF6B7471);

  // Teen Mode (dark) surfaces.
  static const Color night = Color(0xFF121615);
  static const Color nightSurface = Color(0xFF1B211F);
  static const Color nightCard = Color(0xFF242C29);
  static const Color nightText = Color(0xFFEDEBE6);
  static const Color nightMuted = Color(0xFFA7B0AA);
  static const Color sageGlow = Color(0xFF9DBFA8);

  static const Color error = Color(0xFFB3261E);
}
