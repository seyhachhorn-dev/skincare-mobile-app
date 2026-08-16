import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/order.dart';
import 'package:skincare_app/screens/thank_you_screen.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/payment_service.dart';
import 'package:skincare_app/utils/money.dart';
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
  static const _paymentWindow = Duration(minutes: 5);

  String? _qr;
  String? _merchantName;
  bool _isLoading = true;
  bool _isPaid = false;
  bool _isCancelling = false;
  bool _isExpired = false;
  String? _error;
  Timer? _pollTimer;
  Timer? _countdownTimer;
  DateTime? _expiresAt;
  Duration _timeRemaining = _paymentWindow;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateCode() async {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
      _isExpired = false;
      _timeRemaining = _paymentWindow;
    });

    final response = await PaymentService.instance.generateKhqr(
      widget.order.id,
    );
    if (!mounted) return;

    if (!response.status || response.payment == null) {
      setState(() {
        _isLoading = false;
        _error = response.message.isNotEmpty
            ? response.message
            : 'Could not generate the KHQR code.';
      });
      return;
    }

    setState(() {
      _qr = response.payment!.qr;
      _merchantName = response.payment!.merchantName;
      _isLoading = false;
    });
    _startPolling();
    _startPaymentWindow();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  void _startPaymentWindow([DateTime? deadline]) {
    _countdownTimer?.cancel();
    _expiresAt = deadline ?? DateTime.now().add(_paymentWindow);
    _updateCountdown();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final deadline = _expiresAt;
    if (!mounted || deadline == null || _isExpired || _isPaid) return;

    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();
      setState(() {
        _timeRemaining = Duration.zero;
        _isExpired = true;
      });
      _expirePayment();
      return;
    }

    final roundedSeconds = (remaining.inMilliseconds + 999) ~/ 1000;
    setState(() => _timeRemaining = Duration(seconds: roundedSeconds));
  }

  Future<void> _expirePayment() async {
    if (_isPaid || _isCancelling) return;

    setState(() => _isCancelling = true);
    final response = await PaymentService.instance.cancelKhqr(widget.order.id);
    if (!mounted) return;

    if (!response.status) {
      setState(() {
        _isCancelling = false;
        _error = response.message.isNotEmpty
            ? response.message
            : 'Could not expire this payment yet.';
      });
      return;
    }

    await CartService.instance.load();
    if (!mounted) return;
    setState(() => _isCancelling = false);
  }

  Future<void> _checkStatus() async {
    final response = await PaymentService.instance.checkKhqrStatus(
      widget.order.id,
    );
    if (!mounted || !response.status) return;

    if (response.paid) {
      _pollTimer?.cancel();
      _countdownTimer?.cancel();
      setState(() => _isPaid = true);

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouScreen(order: widget.order),
        ),
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
    _countdownTimer?.cancel();

    final response = await PaymentService.instance.cancelKhqr(widget.order.id);
    if (!mounted) return;

    if (!response.status) {
      setState(() => _isCancelling = false);
      if (_qr != null) {
        _startPolling();
        _startPaymentWindow(_expiresAt);
      }
      AppSnackBar.error(
        context,
        title: "Couldn't cancel",
        message: response.message.isNotEmpty
            ? response.message
            : 'Please try again.',
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
                // The QR card and payment details are taller than the available
                // viewport on smaller devices. Keep short states centered, while
                // allowing the payment form to scroll instead of overflowing.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 24,
                        ),
                        child: Center(child: _buildBody()),
                      ),
                    ),
                  ),
                ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
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

    if (_isExpired) {
      return _buildExpiredBody();
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textDark,
            ),
            child: const Text(
              'Try again',
              style: TextStyle(color: Colors.white),
            ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
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
          Money.usd(widget.order.total),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppString.khqrInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${AppString.khqrWaiting} (${_countdownLabel()} remaining)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textGrey,
                  ),
                )
              : const Text(
                  AppString.khqrCancel,
                  style: TextStyle(color: AppColors.textGrey),
                ),
        ),
      ],
    );
  }

  Widget _buildExpiredBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_off_outlined, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        const Text(
          'Payment time expired',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isCancelling
              ? 'Returning your items to the cart...'
              : _error ??
                    'The five-minute KHQR payment window is over. Your items are back in your cart.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isCancelling
                ? null
                : () {
                    if (_error != null) {
                      _expirePayment();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textDark,
            ),
            child: _isCancelling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_error == null ? 'Back to checkout' : 'Try again'),
          ),
        ),
      ],
    );
  }

  String _countdownLabel() {
    final minutes = _timeRemaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_timeRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/KHQR_Logo.svg.webp',
            height: 30,
            fit: BoxFit.contain,
          ),
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
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(26, 26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            (_merchantName == null || _merchantName!.isEmpty)
                ? ''
                : _merchantName!.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
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
  static const _cornerLength = 26.0;
  static const _thickness = 3.0;
  static const _radius = 10.0;

  final Color color;

  const _QrCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, _cornerLength)
        ..lineTo(0, _radius)
        ..arcToPoint(Offset(_radius, 0), radius: Radius.circular(_radius))
        ..lineTo(_cornerLength, 0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - _cornerLength, 0)
        ..lineTo(size.width - _radius, 0)
        ..arcToPoint(
          Offset(size.width, _radius),
          radius: Radius.circular(_radius),
        )
        ..lineTo(size.width, _cornerLength),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - _cornerLength)
        ..lineTo(size.width, size.height - _radius)
        ..arcToPoint(
          Offset(size.width - _radius, size.height),
          radius: Radius.circular(_radius),
        )
        ..lineTo(size.width - _cornerLength, size.height),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(_cornerLength, size.height)
        ..lineTo(_radius, size.height)
        ..arcToPoint(
          Offset(0, size.height - _radius),
          radius: Radius.circular(_radius),
        )
        ..lineTo(0, size.height - _cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrCornersPainter oldDelegate) =>
      oldDelegate.color != color;
}
