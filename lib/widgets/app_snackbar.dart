import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';

enum SnackType { error, success, info }

/// Single place for every in-app notification (login/register feedback,
/// add-to-bag, copy-to-clipboard, etc). Floats a rounded, icon + title +
/// message card down from the top of the screen — matching the reference
/// design — then auto-dismisses.
///
/// Built on Overlay/OverlayEntry rather than ScaffoldMessenger.showSnackBar
/// (bottom-only, no "top" mode) or showMaterialBanner (top, but edge-to-edge
/// and non-floating) since neither can produce this look. Inserted into the
/// *root* overlay, so it survives a Navigator.pop() called right after
/// showing it (several call sites do exactly that).
class AppSnackBar {
  AppSnackBar._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    SnackType type = SnackType.info,
  }) {
    _dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (context) => _TopBanner(
        title: title,
        message: message,
        type: type,
        onDismiss: _dismiss,
      ),
    );

    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void error(BuildContext context, {String title = 'Something went wrong', required String message}) {
    show(context, title: title, message: message, type: SnackType.error);
  }

  static void success(BuildContext context, {String title = 'Success', required String message}) {
    show(context, title: title, message: message, type: SnackType.success);
  }

  static void info(BuildContext context, {String title = 'Notice', required String message}) {
    show(context, title: title, message: message, type: SnackType.info);
  }
}

class _TopBanner extends StatefulWidget {
  final String title;
  final String message;
  final SnackType type;
  final VoidCallback onDismiss;

  const _TopBanner({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.type) {
      SnackType.error => AppColors.error,
      SnackType.success => AppColors.success,
      SnackType.info => AppColors.textDark,
    };
    final icon = switch (widget.type) {
      SnackType.error => Icons.error_outline,
      SnackType.success => Icons.check_circle_outline,
      SnackType.info => Icons.info_outline,
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
