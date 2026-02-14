import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/language_state.dart';
import '../state/premium_state.dart';

enum _Plan { yearly, monthly }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  _Plan _selectedPlan = _Plan.yearly;

  Future<void> _purchase() async {
    final premiumState = context.read<PremiumState>();
    final s = context.read<LanguageState>().strings;
    try {
      if (_selectedPlan == _Plan.yearly) {
        await premiumState.purchaseYearly();
      } else {
        await premiumState.purchaseMonthly();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.purchaseFailed('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = context.watch<PremiumState>();
    final s = context.watch<LanguageState>().strings;

    final monthlyPrice = premiumState.monthlyPrice ?? '---';
    final yearlyPrice = premiumState.yearlyPrice ?? '---';

    // Calculate savings percentage
    final monthlyRaw = premiumState.monthlyRawPrice;
    final yearlyRaw = premiumState.yearlyRawPrice;
    final savingsPercent =
        (monthlyRaw != null && yearlyRaw != null && monthlyRaw > 0)
            ? ((1 - yearlyRaw / (monthlyRaw * 12)) * 100).round()
            : 0;
    // Monthly equivalent from yearly price
    final monthlyEquiv = (yearlyRaw != null)
        ? (yearlyRaw / 12).toStringAsFixed(0)
        : '---';
    final currencySymbol = premiumState.currencySymbol ?? '';
    final monthlyEquivLabel = '$currencySymbol$monthlyEquiv';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 64),
              const SizedBox(height: 16),
              const Text(
                'Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.unlockAll,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Features list
              ...s.premiumFeatures.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF533483), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),
              // Yearly plan (selectable)
              _PlanCard(
                title: s.yearlyPlan,
                price: s.yearlyPriceLabel(yearlyPrice),
                originalPrice: (monthlyRaw != null)
                    ? '$currencySymbol${(monthlyRaw * 12).toStringAsFixed(0)}'
                    : null,
                savingsPercent: savingsPercent > 0 ? savingsPercent : null,
                subtitle:
                    s.yearlySubtitle(monthlyEquivLabel, savingsPercent),
                isSelected: _selectedPlan == _Plan.yearly,
                recommendedLabel: s.recommended,
                onTap: () => setState(() => _selectedPlan = _Plan.yearly),
              ),
              const SizedBox(height: 12),
              // Monthly plan (selectable)
              _PlanCard(
                title: s.monthlyPlan,
                price: s.monthlyPriceLabel(monthlyPrice),
                subtitle: '',
                isSelected: _selectedPlan == _Plan.monthly,
                recommendedLabel: '',
                onTap: () => setState(() => _selectedPlan = _Plan.monthly),
              ),
              const SizedBox(height: 32),
              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _purchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF533483),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    s.subscribe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await premiumState.restorePurchases();
                  if (context.mounted && premiumState.isPremium) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  s.restorePurchase,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? originalPrice;
  final int? savingsPercent;
  final String subtitle;
  final bool isSelected;
  final String recommendedLabel;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    this.originalPrice,
    this.savingsPercent,
    required this.subtitle,
    required this.isSelected,
    required this.recommendedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F3460)
              : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF533483)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF533483)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recommendedLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF533483),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recommendedLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  Text(
                    title,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  if (originalPrice != null && savingsPercent != null) ...[
                    Row(
                      children: [
                        Text(
                          originalPrice!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-$savingsPercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
