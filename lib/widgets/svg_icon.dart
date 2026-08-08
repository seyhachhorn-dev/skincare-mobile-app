import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a Figma-exported icon asset, tinted like a Material [Icon].
class SvgIcon extends StatelessWidget {
  final String asset;
  final Color color;
  final double size;

  const SvgIcon(this.asset, {super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
