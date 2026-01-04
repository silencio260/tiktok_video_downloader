import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/analytics_event.dart' as entity;
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/usecases/log_event_usecase.dart';
import '../../domain/usecases/log_ad_revenue_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;
  final LogEventUseCase logEventUseCase;
  final LogAdRevenueUseCase logAdRevenueUseCase;

  AnalyticsBloc({
    required this.repository,
    required this.logEventUseCase,
    required this.logAdRevenueUseCase,
  }) : super(const AnalyticsInitial()) {
    on<AnalyticsInitialize>(_onInitialize);
    on<AnalyticsLogEvent>(_onLogEvent);
    on<AnalyticsLogAdRevenue>(_onLogAdRevenue);
    on<AnalyticsSetUserId>(_onSetUserId);
  }

  Future<void> _onInitialize(
    AnalyticsInitialize event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await repository.initialize();
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.message)),
      (_) => emit(const AnalyticsInitialized()),
    );
  }

  Future<void> _onLogEvent(
    AnalyticsLogEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    await logEventUseCase(
      entity.AnalyticsEvent(name: event.name, parameters: event.parameters),
    );
  }

  Future<void> _onSetUserId(
    AnalyticsSetUserId event,
    Emitter<AnalyticsState> emit,
  ) async {
    await repository.setUserId(event.userId);
  }

  Future<void> _onLogAdRevenue(
    AnalyticsLogAdRevenue event,
    Emitter<AnalyticsState> emit,
  ) async {
    await logAdRevenueUseCase(event.revenueEvent);
  }
}
