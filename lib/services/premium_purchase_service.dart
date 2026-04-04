import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPurchaseService {
  PremiumPurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  static const String premiumProductId = 'starkind_premium_feelings';

  final InAppPurchase _inAppPurchase;

  Future<PremiumOfferResult> loadPremiumOffer() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      return const PremiumOfferResult.unavailable(
        message: 'Purchases are not available right now.',
      );
    }

    final response = await _inAppPurchase.queryProductDetails({
      premiumProductId,
    });

    if (response.error != null) {
      return PremiumOfferResult.unavailable(message: response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      return const PremiumOfferResult.unavailable(
        message: 'Premium is currently unavailable.',
      );
    }

    final product = response.productDetails.first;
    return PremiumOfferResult.available(product: product);
  }

  Future<PurchaseActionResult> purchasePremium({
    required ProductDetails product,
  }) {
    return _runPurchaseFlow(
      trigger: () {
        return _inAppPurchase.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: product),
        );
      },
      allowPurchased: true,
      allowRestored: true,
    );
  }

  Future<PurchaseActionResult> restorePremium() {
    return _runPurchaseFlow(
      trigger: _inAppPurchase.restorePurchases,
      allowPurchased: false,
      allowRestored: true,
    );
  }

  Future<PurchaseActionResult> _runPurchaseFlow({
    required Future<void> Function() trigger,
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
        for (final purchase in purchaseDetailsList) {
          switch (purchase.status) {
            case PurchaseStatus.pending:
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

          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }
        }
      },
      onError: (Object _) {
        finish(
          const PurchaseActionResult.failed(
            message: 'Purchase service is temporarily unavailable.',
          ),
        );
      },
    );

    try {
      await trigger();
      final result = await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () => const PurchaseActionResult.failed(
          message: 'No purchase confirmation was received.',
        ),
      );
      return result;
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
