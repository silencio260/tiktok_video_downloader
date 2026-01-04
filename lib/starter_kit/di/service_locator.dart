/// Simple service locator for dependency injection
///
/// Usage:
/// ```dart
/// // Register a service
/// ServiceLocator.register<MyService>(MyService());
///
/// // Get a service
/// final service = ServiceLocator.get<MyService>();
/// ```

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic Function()> _factories = {};

  /// Register a singleton service instance
  static void register<T>(T service) {
    _instance._services[T] = service;
  }

  /// Register a factory function for lazy instantiation
  static void registerFactory<T>(T Function() factory) {
    _instance._factories[T] = factory;
  }

  /// Get a registered service (returns null if not found)
  static T? get<T>() {
    // First check if singleton exists
    if (_instance._services.containsKey(T)) {
      return _instance._services[T] as T;
    }

    // Then check if factory exists
    if (_instance._factories.containsKey(T)) {
      final service = _instance._factories[T]!() as T;
      _instance._services[T] = service; // Cache the instance
      return service;
    }

    return null;
  }

  /// Get a registered service (throws if not found)
  static T getRequired<T>() {
    final service = get<T>();
    if (service == null) {
      throw StateError('Service of type $T not registered in ServiceLocator');
    }
    return service;
  }

  /// Check if a service is registered
  static bool isRegistered<T>() {
    return _instance._services.containsKey(T) ||
        _instance._factories.containsKey(T);
  }

  /// Unregister a service
  static void unregister<T>() {
    _instance._services.remove(T);
    _instance._factories.remove(T);
  }

  /// Clear all registered services (useful for testing)
  static void reset() {
    _instance._services.clear();
    _instance._factories.clear();
  }
}
