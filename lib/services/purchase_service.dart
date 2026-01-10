import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product ID for premium upgrade - must match Google Play Console
const String premiumProductId = 'premium_upgrade';

/// Price for premium (for display purposes)
const String premiumPrice = '\$1.99';

/// Service for handling in-app purchases.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Controller for premium status changes
  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  bool _isAvailable = false;
  bool _isPremium = false;
  ProductDetails? _premiumProduct;

  bool get isAvailable => _isAvailable;
  bool get isPremium => _isPremium;
  ProductDetails? get premiumProduct => _premiumProduct;

  /// Initialize the purchase service.
  Future<void> initialize() async {
    // Check if store is available
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      debugPrint('PurchaseService: Store not available');
      // Still check local storage for premium status
      await _loadPremiumStatus();
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _onPurchaseStreamDone,
      onError: _onPurchaseStreamError,
    );

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await restorePurchases();

    // Load local premium status
    await _loadPremiumStatus();
  }

  /// Load available products from the store.
  Future<void> _loadProducts() async {
    final response =
        await _inAppPurchase.queryProductDetails({premiumProductId});

    if (response.error != null) {
      debugPrint('PurchaseService: Error loading products: ${response.error}');
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          'PurchaseService: Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      _premiumProduct = response.productDetails.first;
      debugPrint(
          'PurchaseService: Loaded product: ${_premiumProduct?.title} - ${_premiumProduct?.price}');
    }
  }

  /// Handle purchase updates.
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle a single purchase.
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      debugPrint('PurchaseService: Purchase pending...');
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('PurchaseService: Purchase error: ${purchaseDetails.error}');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Verify and grant premium
      if (purchaseDetails.productID == premiumProductId) {
        await _grantPremium();
        debugPrint('PurchaseService: Premium granted!');
      }
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      debugPrint('PurchaseService: Purchase canceled');
    }

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Grant premium access to the user.
  Future<void> _grantPremium() async {
    _isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    _premiumStatusController.add(true);
  }

  /// Load premium status from local storage.
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _premiumStatusController.add(_isPremium);
  }

  /// Purchase premium upgrade.
  Future<bool> purchasePremium() async {
    if (!_isAvailable) {
      debugPrint('PurchaseService: Store not available');
      return false;
    }

    if (_premiumProduct == null) {
      debugPrint('PurchaseService: Premium product not loaded');
      // Try to reload products
      await _loadProducts();
      if (_premiumProduct == null) {
        return false;
      }
    }

    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);

    try {
      // Non-consumable purchase (one-time)
      return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('PurchaseService: Purchase failed: $e');
      return false;
    }
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: Restore failed: $e');
    }
  }

  void _onPurchaseStreamDone() {
    _subscription?.cancel();
  }

  void _onPurchaseStreamError(dynamic error) {
    debugPrint('PurchaseService: Stream error: $error');
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _premiumStatusController.close();
  }
}
