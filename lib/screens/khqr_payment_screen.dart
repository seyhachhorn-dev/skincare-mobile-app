import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/order.dart';
import 'package:skincare_app/screens/thank_you_screen.dart';
import 'package:skincare_app/services/payment_service.dart';

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
  bool _isLoading = true;
  bool _isPaid = false;
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

  void _cancel() {
    _pollTimer?.cancel();
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
            onPressed: _cancel,
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: QrImageView(data: _qr!, size: 220, backgroundColor: Colors.white),
        ),
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
          onPressed: _cancel,
          child: const Text(AppString.khqrCancel, style: TextStyle(color: AppColors.textGrey)),
        ),
      ],
    );
  }
}
