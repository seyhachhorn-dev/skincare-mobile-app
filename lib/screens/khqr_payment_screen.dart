import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/order.dart';
import 'package:skincare_app/screens/thank_you_screen.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/payment_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

/// Shown right after placing an order with payment_method=bakong_khqr.
/// Renders the KHQR code returned by the backend and polls order payment
/// status until the customer's bank confirms the transfer.
class KhqrPaymentScreen extends StatefulWidget {
  final Order order;
  const KhqrPaymentScreen({super.key, required this.order});

  @override
  State<KhqrPaymentScreen> createState() => _KhqrPaymentScreenState();
}

class _KhqrPaymentScreenState extends State<KhqrPaymentScreen> {
  static const _pollInterval = Duration(seconds: 4);

  String? _qr;
  String? _merchantName;
  bool _isLoading = true;
  bool _isPaid = false;
  bool _isCancelling = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await PaymentService.instance.generateKhqr(widget.order.id);
    if (!mounted) return;

    if (!response.status || response.payment == null) {
      setState(() {
        _isLoading = false;
        _error = response.message.isNotEmpty ? response.message : 'Could not generate the KHQR code.';
      });
      return;
    }

    setState(() {
      _qr = response.payment!.qr;
      _merchantName = response.payment!.merchantName;
      _isLoading = false;
    });
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    final response = await PaymentService.instance.checkKhqrStatus(widget.order.id);
    if (!mounted || !response.status) return;

    if (response.paid) {
      _pollTimer?.cancel();
      setState(() => _isPaid = true);

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThankYouScreen(order: widget.order)),
      );
    }
  }

  /// Backing out of a pending KHQR order without telling the server would
  /// leave the order (and the cart items it took) stranded — the cart was
  /// already emptied server-side the moment the order was placed. This
  /// asks the server to cancel it, which hands the items back to the
  /// cart, before actually leaving the screen.
  Future<void> _cancel() async {
    if (_isPaid || _isCancelling) return;

    setState(() => _isCancelling = true);
    _pollTimer?.cancel();

    final response = await PaymentService.instance.cancelKhqr(widget.order.id);
    if (!mounted) return;

    if (!response.status) {
      setState(() => _isCancelling = false);
      if (_qr != null) _startPolling();
      AppSnackBar.error(
        context,
        title: "Couldn't cancel",
        message: response.message.isNotEmpty ? response.message : 'Please try again.',
      );
      return;
    }

    await CartService.instance.load();
    if (!mounted) return;

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                Expanded(child: Center(child: _buildBody())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: _isCancelling ? null : _cancel,
          ),
          const Expanded(
            child: Text(
              AppString.khqrTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: AppColors.accent);
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateCode,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textDark),
            child: const Text('Try again', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    if (_isPaid) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          const Text(
            AppString.khqrPaid,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.success),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKhqrCard(),
        const SizedBox(height: 20),
        Text(
          AppString.khqrAmountDue,
          style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        const SizedBox(height: 4),
        Text(
          "\$${widget.order.total}.00 USD",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 20),
        Text(
          AppString.khqrInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            const Text(
              AppString.khqrWaiting,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _isCancelling ? null : _cancel,
          child: _isCancelling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textGrey),
                )
              : const Text(AppString.khqrCancel, style: TextStyle(color: AppColors.textGrey)),
        ),
      ],
    );
  }

  // ---------- KHQR MERCHANT CARD ----------
  Widget _buildKhqrCard() {
    const qrSize = 200.0;
    const frameSize = 248.0;

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/KHQR_Logo.svg.webp', height: 30, fit: BoxFit.contain),
          const SizedBox(height: 10),
          const Text(
            AppString.khqrTagline,
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(frameSize, frameSize),
                  painter: const _QrCornersPainter(color: AppColors.border),
                ),
                QrImageView(
                  data: _qr!,
                  size: qrSize,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  embeddedImage: const AssetImage('assets/icons/khqricon.png'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(26, 26)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            (_merchantName == null || _merchantName!.isEmpty) ? '' : _merchantName!.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            "Order ID: ${widget.order.orderNumber}",
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

/// Rounded corner-bracket "viewfinder" frame drawn around the QR, matching
/// the KHQR reference card design (open brackets, not a full border).
class _QrCornersPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double thickness;
  final double radius;

  const _QrCornersPainter({
    required this.color,
    this.cornerLength = 26,
    this.thickness = 3,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
        ..lineTo(cornerLength, 0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
        ..lineTo(size.width, cornerLength),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius))
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(radius, size.height)
        ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius))
        ..lineTo(0, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrCornersPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.thickness != thickness ||
      oldDelegate.radius != radius;
}
