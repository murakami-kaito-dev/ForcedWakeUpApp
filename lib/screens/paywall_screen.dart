import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/premium_state.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premiumState = context.watch<PremiumState>();

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
                '全ての機能をアンロック',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Features list
              ..._buildFeatureList(),
              const SizedBox(height: 32),
              // Yearly plan
              _PlanCard(
                title: '年額プラン',
                price: '¥5,000 / 年',
                subtitle: '7日間の無料トライアル付き・月額換算 約¥417',
                isRecommended: true,
                onTap: () async {
                  try {
                    await premiumState.purchaseYearly();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('購入失敗: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              // Monthly plan
              _PlanCard(
                title: '月額プラン',
                price: '¥500 / 月',
                subtitle: '',
                isRecommended: false,
                onTap: () async {
                  try {
                    await premiumState.purchaseMonthly();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('購入失敗: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  await premiumState.restorePurchases();
                  if (context.mounted && premiumState.isPremium) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  '購入を復元',
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

  List<Widget> _buildFeatureList() {
    final features = [
      'バーピー・読書・勉強ミッション',
      '回数・秒数のカスタマイズ',
      'アラーム音の選択',
      '音量調整',
      '達成統計・連続記録',
      'SNSシェア機能',
    ];

    return features
        .map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF533483), size: 20),
                  const SizedBox(width: 12),
                  Text(f, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ))
        .toList();
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isRecommended,
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
          color: isRecommended
              ? const Color(0xFF0F3460)
              : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended
                ? const Color(0xFF533483)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF533483),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'おすすめ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
