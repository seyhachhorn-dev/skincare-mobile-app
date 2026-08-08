import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex = 0;

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      "How do I know which products are right for my skin?",
      "Answer a few quick questions in Tell Us About Your Skin during onboarding, or browse by "
          "category on the Explore tab — we surface products suited to your skin type and concerns.",
    ),
    _FaqItem(
      "How long does shipping take?",
      "At checkout you can choose DHL (5-7 business days) or InPost (3-4 business days). "
          "Orders are typically processed within 1-2 business days before shipping.",
    ),
    _FaqItem(
      "Can I return a product once I've opened it?",
      "Unopened items can be returned within 30 days of delivery for a full refund. "
          "Opened items aren't eligible for return for hygiene reasons.",
    ),
    _FaqItem(
      "How do reward points work?",
      "You earn points on every order — roughly 10% of your order total — shown at checkout "
          "and again on your order confirmation. Points add up in your Profile.",
    ),
    _FaqItem(
      "How do I save a product for later?",
      "Tap the heart icon on any product card or on the product page. Saved items appear "
          "under the Saved tab so you can find them again anytime.",
    ),
  ];

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: AppString.supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppString.emailCopied),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
      ),
    );
  }

  void _showChatComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppString.liveChatComingSoon),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    AppString.faqTitle,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_faqs.length, (index) => _buildFaqTile(index)),
                  const SizedBox(height: 24),
                  const Text(
                    AppString.contactUs,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile(
                    icon: Icons.email_outlined,
                    title: AppString.emailSupport,
                    subtitle: AppString.supportEmail,
                    onTap: _copyEmail,
                  ),
                  const SizedBox(height: 10),
                  _buildContactTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: AppString.liveChat,
                    subtitle: "Available 9am-6pm, Mon-Fri",
                    onTap: _showChatComingSoon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              AppString.helpSupport,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFaqTile(int index) {
    final faq = _faqs[index];
    final expanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => setState(() => _expandedIndex = expanded ? null : index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                  ),
                  Icon(expanded ? Icons.remove : Icons.add, size: 18, color: AppColors.textDark),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                Text(
                  faq.answer,
                  style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textDark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
