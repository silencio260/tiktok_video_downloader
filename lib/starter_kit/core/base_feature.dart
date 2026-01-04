/// Base class for all StarterKit features
///
/// Provides common initialization pattern and lifecycle management.

abstract class BaseFeature {
  bool _isInitialized = false;

  /// Returns true if this feature has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the feature with configuration
  /// Subclasses should override [onInitialize] instead of this method
  Future<void> initialize() async {
    if (_isInitialized) {
      print('${runtimeType}: Already initialized, skipping');
      return;
    }

    try {
      await onInitialize();
      _isInitialized = true;
      print('${runtimeType}: Initialized successfully');
    } catch (e) {
      print('${runtimeType}: Initialization failed: $e');
      rethrow;
    }
  }

  /// Override this method to provide feature-specific initialization
  Future<void> onInitialize();

  /// Dispose of resources
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await onDispose();
      _isInitialized = false;
      print('${runtimeType}: Disposed');
    } catch (e) {
      print('${runtimeType}: Dispose failed: $e');
    }
  }

  /// Override this method to provide feature-specific cleanup
  Future<void> onDispose() async {}
}
