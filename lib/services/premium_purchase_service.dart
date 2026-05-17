import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPurchaseService {
  PremiumPurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  static const String premiumProductId = 'starkind_premium_feelings';

  final InAppPurchase _inAppPurchase;

  Future<PremiumOfferResult> loadPremiumOffer() async {
    debugPrint('[IAP] loadPremiumOffer start');
    final available = await _inAppPurchase.isAvailable();
    debugPrint('[IAP] store available = $available');
    if (!available) {
      return const PremiumOfferResult.unavailable(
        message: 'Purchases are not available right now.',
      );
    }

    debugPrint('[IAP] querying product: $premiumProductId');
    final response = await _inAppPurchase.queryProductDetails({
      premiumProductId,
    });

    if (response.error != null) {
      debugPrint('[IAP] queryProductDetails error: ${response.error!.message}');
      return PremiumOfferResult.unavailable(message: response.error!.message);
    }

    debugPrint('[IAP] product count: ${response.productDetails.length}');
    if (response.productDetails.isEmpty) {
      return const PremiumOfferResult.unavailable(
        message: 'Premium is currently unavailable.',
      );
    }

    final product = response.productDetails.first;
    debugPrint('[IAP] product loaded:');
    debugPrint('[IAP]   id: ${product.id}');
    debugPrint('[IAP]   title: ${product.title}');
    debugPrint('[IAP]   price: ${product.price}');
    return PremiumOfferResult.available(product: product);
  }

  Future<PurchaseActionResult> purchasePremium({
    required ProductDetails product,
  }) {
    debugPrint('[IAP] purchasePremium: ${product.id}');
    return _runPurchaseFlow(
      trigger: () async {
        debugPrint('[IAP] calling buyNonConsumable...');
        final ok = await _inAppPurchase.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: product),
        );
        debugPrint('[IAP] buyNonConsumable returned: $ok');
        return ok;
      },
      allowPurchased: true,
      allowRestored: true,
    );
  }

  Future<PurchaseActionResult> restorePremium() {
    debugPrint('[IAP] restorePremium start');
    return _runPurchaseFlow(
      trigger: () async {
        await _inAppPurchase.restorePurchases();
        return true;
      },
      allowPurchased: false,
      allowRestored: true,
    );
  }

  Future<PurchaseActionResult> _runPurchaseFlow({
    required Future<bool> Function() trigger,
    required bool allowPurchased,
    required bool allowRestored,
  }) async {
    final completer = Completer<PurchaseActionResult>();
    late final StreamSubscription<List<PurchaseDetails>> subscription;

    void finish(PurchaseActionResult result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) async {
        debugPrint('[IAP] purchaseStream event: ${purchaseDetailsList.length} item(s)');
        for (final purchase in purchaseDetailsList) {
          debugPrint('[IAP]   productID=${purchase.productID}');
          debugPrint('[IAP]   status=${purchase.status}');
          debugPrint('[IAP]   pendingCompletePurchase=${purchase.pendingCompletePurchase}');
          debugPrint('[IAP]   error=${purchase.error}');

          // Complete the purchase with the store before resolving the flow,
          // so the acknowledgement isn't racing against subscription.cancel().
          if (purchase.pendingCompletePurchase) {
            debugPrint('[IAP]   completing purchase...');
            await _inAppPurchase.completePurchase(purchase);
            debugPrint('[IAP]   completePurchase done');
          }

          switch (purchase.status) {
            case PurchaseStatus.pending:
              debugPrint('[IAP]   status=pending, waiting...');
              break;
            case PurchaseStatus.purchased:
              if (allowPurchased) {
                finish(const PurchaseActionResult.success());
              }
              break;
            case PurchaseStatus.restored:
              if (allowRestored) {
                finish(const PurchaseActionResult.success(restored: true));
              }
              break;
            case PurchaseStatus.error:
              finish(
                PurchaseActionResult.failed(
                  message:
                      purchase.error?.message ??
                      'Purchase could not be completed.',
                ),
              );
              break;
            case PurchaseStatus.canceled:
              finish(
                const PurchaseActionResult.failed(
                  message: 'Purchase canceled.',
                ),
              );
              break;
          }
        }
      },
      onError: (Object e) {
        debugPrint('[IAP] purchaseStream error: $e');
        finish(
          const PurchaseActionResult.failed(
            message: 'Purchase service is temporarily unavailable.',
          ),
        );
      },
    );

    try {
      final started = await trigger().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          debugPrint('[IAP] trigger() timed out');
          return false;
        },
      );
      if (!started) {
        subscription.cancel();
        return const PurchaseActionResult.failed(
          message: 'Unable to start purchase flow right now.',
        );
      }

      debugPrint('[IAP] waiting for purchaseStream result (60s timeout)...');
      final result = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('[IAP] completer timed out — no stream event received');
          return const PurchaseActionResult.failed(
            message: 'No purchase confirmation was received.',
          );
        },
      );
      debugPrint('[IAP] flow complete: success=${result.isSuccess} msg=${result.message}');
      return result;
    } catch (e, st) {
      debugPrint('[IAP] _runPurchaseFlow exception: $e');
      debugPrint('$st');
      return const PurchaseActionResult.failed(
        message: 'Purchase service is temporarily unavailable.',
      );
    } finally {
      await subscription.cancel();
    }
  }
}

class PremiumOfferResult {
  const PremiumOfferResult._({
    required this.isAvailable,
    this.product,
    this.message,
  });

  const PremiumOfferResult.available({required ProductDetails product})
    : this._(isAvailable: true, product: product);

  const PremiumOfferResult.unavailable({required String message})
    : this._(isAvailable: false, message: message);

  final bool isAvailable;
  final ProductDetails? product;
  final String? message;
}

class PurchaseActionResult {
  const PurchaseActionResult._({
    required this.isSuccess,
    this.restored = false,
    this.message,
  });

  const PurchaseActionResult.success({bool restored = false})
    : this._(isSuccess: true, restored: restored);

  const PurchaseActionResult.failed({required String message})
    : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final bool restored;
  final String? message;
}
