import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/subscription_status.dart';
import 'iap_remote_data_source.dart';

/// RevenueCat implementation of IapRemoteDataSource
///
/// To switch to a different provider (e.g., Adapty), create a new class
/// that implements IapRemoteDataSource and register it in the injector.
class RevenueCatDataSource implements IapRemoteDataSource {
  bool _isInitialized = false;

  @override
  Future<void> initialize(String apiKey) async {
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isInitialized = true;
    } catch (e) {
      throw ConfigurationException(
        message: 'Failed to initialize RevenueCat: $e',
      );
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfoToStatus(customerInfo);
    } catch (e) {
      throw PurchaseException(message: 'Failed to get subscription status: $e');
    }
  }

  @override
  Future<List<Product>> getProducts(List<String> productIds) async {
    _ensureInitialized();
    try {
      final offerings = await Purchases.getOfferings();
      final products = <Product>[];

      if (offerings.current != null) {
        for (final package in offerings.current!.availablePackages) {
          final storeProduct = package.storeProduct;
          products.add(
            Product(
              id: storeProduct.identifier,
              title: storeProduct.title,
              description: storeProduct.description,
              price: storeProduct.priceString,
              priceAmount: storeProduct.price,
              currencyCode: storeProduct.currencyCode,
              type: _mapProductType(package.packageType),
            ),
          );
        }
      }

      return products;
    } catch (e) {
      throw PurchaseException(message: 'Failed to get products: $e');
    }
  }

  @override
  Future<SubscriptionStatus> purchaseProduct(String productId) async {
    _ensureInitialized();
    try {
      final offerings = await Purchases.getOfferings();
      Package? packageToPurchase;

      if (offerings.current != null) {
        for (final package in offerings.current!.availablePackages) {
          if (package.storeProduct.identifier == productId) {
            packageToPurchase = package;
            break;
          }
        }
      }

      if (packageToPurchase == null) {
        throw PurchaseException(message: 'Product not found: $productId');
      }

      // ignore: deprecated_member_use
      final dynamic result = await Purchases.purchasePackage(packageToPurchase);

      // Handle both old (CustomerInfo) and new (PurchaseResult) return types
      final CustomerInfo customerInfo =
          result is CustomerInfo ? result : (result as dynamic).customerInfo;

      return _mapCustomerInfoToStatus(customerInfo);
    } on PurchasesErrorCode catch (e) {
      throw PurchaseException(message: 'Purchase failed: ${e.name}');
    } catch (e) {
      throw PurchaseException(message: 'Purchase failed: $e');
    }
  }

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfoToStatus(customerInfo);
    } catch (e) {
      throw PurchaseException(message: 'Failed to restore purchases: $e');
    }
  }

  @override
  Future<List<Entitlement>> getEntitlements() async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all.entries.map((entry) {
        final e = entry.value;
        return Entitlement(
          id: entry.key,
          isActive: e.isActive,
          expirationDate:
              e.expirationDate != null
                  ? DateTime.parse(e.expirationDate!)
                  : null,
          productId: e.productIdentifier,
          willRenew: e.willRenew,
        );
      }).toList();
    } catch (e) {
      throw PurchaseException(message: 'Failed to get entitlements: $e');
    }
  }

  @override
  Future<bool> isEntitlementActive(String entitlementId) async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      throw PurchaseException(message: 'Failed to check entitlement: $e');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    _ensureInitialized();
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      throw PurchaseException(message: 'Failed to set user ID: $e');
    }
  }

  @override
  Future<void> logOut() async {
    _ensureInitialized();
    try {
      await Purchases.logOut();
    } catch (e) {
      throw PurchaseException(message: 'Failed to log out: $e');
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const ConfigurationException(message: 'RevenueCat not initialized');
    }
  }

  SubscriptionStatus _mapCustomerInfoToStatus(CustomerInfo customerInfo) {
    final activeEntitlements = customerInfo.entitlements.active;

    if (activeEntitlements.isEmpty) {
      return const SubscriptionStatus.free();
    }

    final firstActive = activeEntitlements.entries.first;
    return SubscriptionStatus(
      isPremium: true,
      activeEntitlementId: firstActive.key,
      expirationDate:
          firstActive.value.expirationDate != null
              ? DateTime.parse(firstActive.value.expirationDate!)
              : null,
      willRenew: firstActive.value.willRenew,
      activeProductId: firstActive.value.productIdentifier,
    );
  }

  ProductType _mapProductType(PackageType packageType) {
    switch (packageType) {
      case PackageType.lifetime:
        return ProductType.nonConsumable;
      case PackageType.annual:
      case PackageType.sixMonth:
      case PackageType.threeMonth:
      case PackageType.twoMonth:
      case PackageType.monthly:
      case PackageType.weekly:
        return ProductType.subscription;
      default:
        return ProductType.consumable;
    }
  }
}
