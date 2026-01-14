import 'package:equatable/equatable.dart';
import '../../domain/entities/ad_revenue_event.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitialize extends AnalyticsEvent {
  const AnalyticsInitialize();
}

class AnalyticsLogEvent extends AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;

  const AnalyticsLogEvent({required this.name, this.parameters = const {}});

  @override
  List<Object?> get props => [name, parameters];
}

class AnalyticsSetUserId extends AnalyticsEvent {
  final String userId;

  const AnalyticsSetUserId({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AnalyticsLogAdRevenue extends AnalyticsEvent {
  final AdRevenueEvent revenueEvent;

  const AnalyticsLogAdRevenue(this.revenueEvent);

  @override
  List<Object?> get props => [revenueEvent];
}

class AnalyticsLogRetention extends AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;

  const AnalyticsLogRetention({required this.name, this.parameters = const {}});

  @override
  List<Object?> get props => [name, parameters];
}

class AnalyticsLogUserSegment extends AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;

  const AnalyticsLogUserSegment({
    required this.name,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [name, parameters];
}

class AnalyticsLogTargeting extends AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;

  const AnalyticsLogTargeting({required this.name, this.parameters = const {}});

  @override
  List<Object?> get props => [name, parameters];
}

class AnalyticsRecordFlutterError extends AnalyticsEvent {
  final dynamic error;
  final dynamic stack;
  final bool fatal;

  const AnalyticsRecordFlutterError({
    required this.error,
    required this.stack,
    this.fatal = false,
  });

  @override
  List<Object?> get props => [error, stack, fatal];
}

class AnalyticsRecordError extends AnalyticsEvent {
  final dynamic error;
  final dynamic stack;
  final bool fatal;

  const AnalyticsRecordError({
    required this.error,
    required this.stack,
    this.fatal = false,
  });

  @override
  List<Object?> get props => [error, stack, fatal];
}
