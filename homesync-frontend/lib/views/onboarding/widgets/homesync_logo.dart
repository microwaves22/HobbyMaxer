import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shared HomeSync logo: sage rounded square with a home glyph.
class HomeSyncLogo extends StatelessWidget {
  const HomeSyncLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.sage.withValues(alpha: 0.4),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(
        Icons.home_rounded,
        size: size * 0.52,
        color: AppColors.white,
      ),
    );
  }
}
