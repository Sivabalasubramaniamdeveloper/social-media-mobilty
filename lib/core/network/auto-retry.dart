import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final Dio dio;
  final Connectivity connectivity;

  RetryOnConnectionChangeInterceptor({
    required this.dio,
    required this.connectivity,
  });

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry if it was a connectivity error
    if (_shouldRetry(err)) {
      try {
        // Wait until connection is back
        await _waitForConnection();

        // Clone & retry request
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err); // Give up
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown; // Covers no internet
  }

  Future<void> _waitForConnection() async {
    final completer = Completer<void>();
    final sub = connectivity.onConnectivityChanged.listen((status) {
      if (status.first != ConnectivityResult.none) {
        completer.complete();
      }
    });

    return completer.future.whenComplete(() => sub.cancel());
  }
}
