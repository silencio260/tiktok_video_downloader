import '../../domain/entities/analytics_event.dart';
import '../../domain/entities/ad_revenue_event.dart';

/// Abstract data source for analytics providers
abstract class AnalyticsRemoteDataSource {
  Future<void> initialize();
  Future<void> logEvent(AnalyticsEvent event);
  Future<void> logAdRevenue(AdRevenueEvent event);
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  Future<void> logScreenView(String screenName);
}
