import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static const _monthlyId = 'monthly_premium';
  static const _yearlyId = 'yearly_premium';
  static const Set<String> _productIds = {_monthlyId, _yearlyId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> products = [];
  bool _isPremium = false;
  Function(bool)? onPremiumChanged;

  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );

    await _loadProducts();
    await _restorePurchases();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    products = response.productDetails;
  }

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> purchaseMonthly() async {
    final product = products.firstWhere(
      (p) => p.id == _monthlyId,
      orElse: () => throw Exception('Monthly product not found'),
    );
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  Future<void> purchaseYearly() async {
    final product = products.firstWhere(
      (p) => p.id == _yearlyId,
      orElse: () => throw Exception('Yearly product not found'),
    );
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (_productIds.contains(purchase.productID)) {
          _isPremium = true;
          onPremiumChanged?.call(true);
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
