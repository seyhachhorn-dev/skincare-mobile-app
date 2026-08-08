import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class SkipButton extends StatefulWidget {
  final VoidCallback onTap;
  const SkipButton({super.key, required this.onTap});

  @override
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      behavior: HitTestBehavior.opaque, // makes the whole width tappable
      child: Center(
        child: Text(
          AppString.skipForNow,
          style: TextStyle(
            color: AppColors.textGrey,
            decoration: pressed
                ? TextDecoration.underline
                : TextDecoration.none,
           decorationColor: AppColors.textGrey.withValues(alpha: 0.4), 
          ),
        ),
      ),
    );
  }
}