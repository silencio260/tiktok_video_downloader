import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_subscription_status_usecase.dart';
import '../../domain/usecases/purchase_product_usecase.dart';
import '../../domain/usecases/restore_purchases_usecase.dart';
import '../../domain/services/subscription_manager.dart';

part 'iap_event.dart';
part 'iap_state.dart';

/// IAP Bloc for managing subscription state
class IapBloc extends Bloc<IapEvent, IapState> {
  final GetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  final GetProductsUseCase getProductsUseCase;
  final PurchaseProductUseCase purchaseProductUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;

  SubscriptionStatus _currentStatus = const SubscriptionStatus.free();
  List<Product> _products = [];

  /// Quick getter for premium status
  bool get isPremium => SubscriptionManager.instance.isPremium;

  /// Current subscription status
  SubscriptionStatus get currentStatus => _currentStatus;

  /// Available products
  List<Product> get products => _products;

  IapBloc({
    required this.getSubscriptionStatusUseCase,
    required this.getProductsUseCase,
    required this.purchaseProductUseCase,
    required this.restorePurchasesUseCase,
  }) : super(const IapInitial()) {
    on<IapRefreshStatus>(_onRefreshStatus);
    on<IapLoadProducts>(_onLoadProducts);
    on<IapPurchaseProduct>(_onPurchaseProduct);
    on<IapRestorePurchases>(_onRestorePurchases);
  }

  Future<void> _onRefreshStatus(
    IapRefreshStatus event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapLoading());

    final result = await getSubscriptionStatusUseCase();
    result.fold((failure) => emit(IapError(message: failure.message)), (
      status,
    ) {
      _currentStatus = status;
      SubscriptionManager.instance.updateStatus(status);
      emit(IapInitialized(status: status));
    });
  }

  Future<void> _onLoadProducts(
    IapLoadProducts event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapLoading());

    final result = await getProductsUseCase(event.productIds);
    result.fold((failure) => emit(IapError(message: failure.message)), (
      products,
    ) {
      _products = products;
      emit(IapProductsLoaded(products: products, status: _currentStatus));
    });
  }

  Future<void> _onPurchaseProduct(
    IapPurchaseProduct event,
    Emitter<IapState> emit,
  ) async {
    emit(IapPurchasing(productId: event.productId));

    final result = await purchaseProductUseCase(event.productId);
    result.fold((failure) => emit(IapError(message: failure.message)), (
      status,
    ) {
      _currentStatus = status;
      SubscriptionManager.instance.updateStatus(status);
      emit(IapPurchaseSuccess(status: status));
    });
  }

  Future<void> _onRestorePurchases(
    IapRestorePurchases event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapRestoring());

    final result = await restorePurchasesUseCase();
    result.fold((failure) => emit(IapError(message: failure.message)), (
      status,
    ) {
      _currentStatus = status;
      SubscriptionManager.instance.updateStatus(status);
      emit(IapRestoreSuccess(status: status));
    });
  }
}
