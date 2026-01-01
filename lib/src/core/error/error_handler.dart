import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      failure = _handleError(error);
    } else if (error is SocketException) {
      failure = const NoInternetConnectionFailure();
    } else {
      failure = const UnexpectedFailure();
    }
  }
}

Failure _handleError(DioException dioError) {
  switch (dioError.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ConnectTimeOutFailure();
    case DioExceptionType.badResponse:
      return _handleResponseError(dioError.response);
    case DioExceptionType.cancel:
      return const CancelRequestFailure();
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return const NoInternetConnectionFailure();
    default:
      return const UnexpectedFailure();
  }
}

Failure _handleResponseError(Response? response) {
  String? message;
  if (response?.data is Map) {
    message = response?.data['message'];
  } else if (response?.data is String &&
      (response?.data as String).isNotEmpty) {
    // If it's a string, it might be an HTML error but let's see
  }

  switch (response?.statusCode) {
    case 400:
      return const BadRequestFailure();
    case 403:
      return NotSubscribedFailure(
        message:
            message ?? "Access denied (403). The video might be restricted.",
      );
    case 429:
      return TooManyRequestsFailure(
        message: message ?? "Too many requests. Please try again later.",
      );
    case 404:
      return const NotFoundFailure();
    case 500:
      return const ServerFailure();
    default:
      return const UnexpectedFailure();
  }
}
