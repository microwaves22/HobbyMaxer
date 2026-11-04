import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared design tokens for HomeSync Figma file `EBU3PSoyzYehUshVKn4APt`,
/// section 03 (Tasks & Chores).
///
/// Values below are copied exactly from the verified Figma re-pull of
/// Teen My To-Do List (node 100:4622) — do not "improve", paraphrase,
/// or round them. Re-pull DONE: the four open items from the HTTP 429
/// pass (header note, tile colors, corner radius, sizes/line-heights)
/// are resolved against the full node below.
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

  /// Teen My To-Do List canvas (node 100:4622). This screen's variable
  /// set has no cream in it at all — do not substitute [cream] here.
  static const Color teenCanvas = Color(0xFFF4F3EF);

  // Pastels for task tiles / accents.
  static const Color pastelBlue = Color(0xFFCFE0EE);
  static const Color pastelLavender = Color(0xFFDDD5EE);
  static const Color pastelPeach = Color(0xFFF6D9C4);
  static const Color pastelPink = Color(0xFFF4C9C9);
  static const Color pastelYellow = Color(0xFFFDF0C8);

  // 10 Customization background tiles (node 5:248), top -> bottom.
  static const Color skyTop = Color(0xFFCFE3F5);
  static const Color skyBottom = Color(0xFFF5E8D0);
  static const Color meadowTop = Color(0xFFCDE5C0);
  static const Color meadowBottom = Color(0xFFF2F0CC);
  static const Color sunsetTop = Color(0xFFF8D3B8);
  static const Color sunsetBottom = Color(0xFFF2B7C8);
  static const Color nightTop = Color(0xFF3C4572);
  static const Color nightBottom = Color(0xFF8E86C0);

  /// Kids My To-Do List (node 100:4739) aliases. Same values as the
  /// pastels above, named as the screen spec names them.
  static const Color pink = pastelPink;
  static const Color yellowLight = pastelYellow;

  /// Frosted-card fills: `rgba(255,255,255,0.79)` for cards and
  /// `rgba(255,255,255,0.91)` for inputs and the bottom nav.
  static const Color frostedFill = Color.fromRGBO(255, 255, 255, 0.79);
  static const Color frostedStrong = Color.fromRGBO(255, 255, 255, 0.91);

  /// Sarah Task Review (node 62:6347) fills: `rgba(255,255,255,0.72)`
  /// for the main card, the inactive queue tab, the instructions panel,
  /// and the secondary button; `rgba(255,255,255,0.8)` for the bottom
  /// nav container.
  static const Color frostedReview = Color.fromRGBO(255, 255, 255, 0.72);
  static const Color frostedNavReview = Color.fromRGBO(255, 255, 255, 0.8);

  // Teen My To-Do List (node 100:4622) per-state colors. Every
  // tile/row/chip color on that node is FIXED BY STATE — nothing is
  // assigned by rotation or index.

  /// Frosted tile surface (destination, new-task, created-by-me,
  /// parent-tasks cards): `rgba(255,255,255,0.79)`, 9px backdrop blur,
  /// 1px [frostedCardBorder], [FigmaShadows.frostedCard].
  static const Color frostedCardFill = frostedFill;
  static const Color frostedCardBorder = white;

  /// Destination row, CURRENT state background.
  static const Color tileCurrentBg = sageLight;

  /// Destination row, LOCKED state: no fill (transparent on the
  /// frosted card); all text renders in [mute].
  static const Color tileLockedText = mute;

  /// Category chip, SELECTED ("Homework").
  static const Color chipSelectedBg = sage;
  static const Color chipSelectedText = white;

  /// Category chip, UNSELECTED ("Personal goal", "Task").
  static const Color chipUnselectedBg = white;
  static const Color chipUnselectedText = sage;

  /// Completion circle, INCOMPLETE: translucent fill, sageMid ring.
  static const Color completionIncompleteFill = frostedStrong;
  static const Color completionIncompleteBorder = sageMid;

  /// Completion circle, COMPLETE: solid sage with a white check.
  static const Color completionCompleteFill = sage;
  static const Color completionCompleteBorder = sage;
  static const Color completionCompleteIcon = white;

  /// Text-input fill: `rgba(255,255,255,0.91)`.
  static const Color inputFill = frostedStrong;
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

  /// Frosted card on Teen My To-Do List (node 100:4622):
  /// `0px 5px 16px -4px rgba(59,77,56,0.07)`.
  static const BoxShadow frostedCard = BoxShadow(
    color: Color.fromRGBO(59, 77, 56, 0.07),
    offset: Offset(0, 5),
    blurRadius: 16,
    spreadRadius: -4,
  );

  /// Card at the top of the Figma alpha range:
  /// `0px 5px 16px -4px rgba(59,77,56,0.09)`, pinned by 10 Customization
  /// (node 5:248). Differs from [card] only in alpha.
  static const BoxShadow cardDeep = BoxShadow(
    color: Color.fromRGBO(59, 77, 56, 0.09),
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

/// Corner-radius scale confirmed from Teen My To-Do List (node 100:4622).
abstract final class FigmaRadii {
  /// Frosted / standard card.
  static const double card = 22;

  /// Primary button.
  static const double primaryButton = 18;

  /// Dropdown trigger.
  static const double dropdownTrigger = 18;

  /// Destination row.
  static const double destinationRow = 14;

  /// Text inputs.
  static const double textInput = 14;

  /// Category chip.
  static const double chip = 12;

  /// Pills and circles (progress pill, "Current" pill, avatar,
  /// back button, completion circle): fully round.
  static const double pill = 999;
}

/// Standard white card: white background, 1px border
/// `rgba(255,255,255,0.95)`, standard card shadow.
abstract final class FigmaCards {
  static BoxDecoration whiteCard({
    double radius = FigmaRadii.card,
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
/// Sizes and line heights below are the verified node 100:4622 values:
/// 1.35 line height for all text on that screen.
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

  /// Screen title: 26 ExtraBold (node 100:4622 "My To-Do List").
  static TextStyle screenTitle({Color color = FigmaColors.ink}) => _nunito(
        size: 26,
        weight: FontWeight.w800,
        color: color,
        height: 1.35,
      );

  /// Card headings: 17 ExtraBold ("New personal task", "Created by me").
  static TextStyle cardTitle({Color color = FigmaColors.ink}) => _nunito(
        size: 17,
        weight: FontWeight.w800,
        color: color,
        height: 1.35,
      );

  /// Description line: 13 Medium.
  static TextStyle body({Color color = FigmaColors.mute}) => _nunito(
        size: 13,
        weight: FontWeight.w500,
        color: color,
        height: 1.35,
      );

  /// Field labels: 12 ExtraBold.
  static TextStyle label({Color color = FigmaColors.ink}) => _nunito(
        size: 12,
        weight: FontWeight.w800,
        color: color,
        height: 1.35,
      );

  /// Pills / progress: 11 ExtraBold.
  static TextStyle points({Color color = FigmaColors.sageDark}) => _nunito(
        size: 11,
        weight: FontWeight.w800,
        color: color,
        height: 1.35,
      );

  /// Primary button / dropdown trigger text: 15 ExtraBold.
  static TextStyle button({Color color = FigmaColors.white}) => _nunito(
        size: 15,
        weight: FontWeight.w800,
        color: color,
        height: 1.35,
      );
}
