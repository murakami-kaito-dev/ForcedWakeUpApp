import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class PremiumState extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  bool _isPremium = false;

  // For development testing - set to true to bypass payment
  static const bool debugOverridePremium = false;

  PremiumState(this._subscriptionService) {
    _subscriptionService.onPremiumChanged = (value) {
      _isPremium = value;
      notifyListeners();
    };
  }

  bool get isPremium => debugOverridePremium || _isPremium;

  Future<void> initialize() async {
    await _subscriptionService.initialize();
    _isPremium = _subscriptionService.isPremium;
    notifyListeners();
  }

  Future<void> purchaseMonthly() async {
    await _subscriptionService.purchaseMonthly();
  }

  Future<void> purchaseYearly() async {
    await _subscriptionService.purchaseYearly();
  }

  Future<void> restorePurchases() async {
    await _subscriptionService.restorePurchases();
  }
}
