import 'package:get_it/get_it.dart';

import 'data/datasources/iap_remote_data_source.dart';
import 'data/datasources/revenuecat_data_source.dart';
import 'data/repositories/iap_repository_impl.dart';
import 'domain/repositories/iap_repository.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'domain/usecases/get_subscription_status_usecase.dart';
import 'domain/usecases/purchase_product_usecase.dart';
import 'domain/usecases/restore_purchases_usecase.dart';
import 'presentation/bloc/iap_bloc.dart';

/// Initialize IAP feature dependencies
///
/// To use a different IAP provider, replace RevenueCatDataSource with your implementation
void initIapFeature(GetIt sl, {IapRemoteDataSource? customDataSource}) {
  // Data source - use custom or default to RevenueCat
  if (customDataSource != null) {
    sl.registerLazySingleton<IapRemoteDataSource>(() => customDataSource);
  } else {
    sl.registerLazySingleton<IapRemoteDataSource>(() => RevenueCatDataSource());
  }

  // Repository
  sl.registerLazySingleton<IapRepository>(
    () => IapRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetSubscriptionStatusUseCase>(
    () => GetSubscriptionStatusUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<PurchaseProductUseCase>(
    () => PurchaseProductUseCase(repository: sl()),
  );
  sl.registerLazySingleton<RestorePurchasesUseCase>(
    () => RestorePurchasesUseCase(repository: sl()),
  );

  // Bloc
  sl.registerLazySingleton<IapBloc>(
    () => IapBloc(
      getSubscriptionStatusUseCase: sl(),
      getProductsUseCase: sl(),
      purchaseProductUseCase: sl(),
      restorePurchasesUseCase: sl(),
    ),
  );
}
