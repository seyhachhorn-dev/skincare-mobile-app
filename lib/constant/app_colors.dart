import 'package:flutter/material.dart';

/// Brand palette derived from the Hana logo (deep rose + coral pink),
/// balanced with warm neutrals so the app doesn't read as flat red everywhere.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFBD3849); // deep rose — buttons, headings, brand marks
  static const Color primaryDark = Color(0xFF8F2635); // pressed states, gradients
  static const Color primaryLight = Color(0xFFE97B80); // coral pink — secondary accents, highlights

  // Backwards-compatible alias for older call sites.
  static const Color accent = primary;

  // Neutrals (warm-toned, not stark, to keep things feeling natural)
  static const Color background = Color(0xFFFBF3F1); // warm blush-cream page background
  static const Color surface = Color(0xFFFFFFFF); // cards, inputs, sheets
  static const Color border = Color(0xFFF0DCDA); // hairline dividers, input borders

  static const Color textDark = Color(0xFF3A2327); // warm near-black for headings
  static const Color textGrey = Color(0xFF9A8283); // muted rose-grey for body/secondary text

  static const Color success = Color(0xFF6B9E78);
  static const Color error = Color(0xFFBD3849);

  static const List<Color> splashGradient = [
    Color(0xFFFDF0EF),
    Color(0xFFFBDCDB),
  ];
}
