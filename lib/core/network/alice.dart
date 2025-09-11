import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_alice/alice.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auto-retry.dart';

class DioProvider {
  static final DioProvider _singleton = DioProvider._internal();
  static final PrettyDioLogger _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: true,
    error: true,
    compact: false,
    maxWidth: 500,
    request: true,
  );
  factory DioProvider() => _singleton;

  DioProvider._internal();

  late Dio dio;
  Alice alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    notificationIcon: Headers.jsonContentType,
    darkTheme: true,
  );

  initAlice(Alice aliceInstance) async {
    alice = aliceInstance;
    dio = Dio();
    final connectivity = Connectivity();

    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(dio: dio, connectivity: connectivity),
    );
    // final sslCertificate = await rootBundle.load(
    //   'assets/Certificates/sit_certificate.pem',
    // );
    // final securityContext = SecurityContext(withTrustedRoots: false)
    //   ..setTrustedCertificatesBytes(sslCertificate.buffer.asUint8List());

    // final httpClient = HttpClient(context: securityContext);
    // httpClient.badCertificateCallback = (
    //     X509Certificate cert,
    //     String host,
    //     int port,
    //     ) {
    //   return true;
    // };

    dio.interceptors.add(alice.getDioInterceptor());
    dio.interceptors.add(_logger);
  }

  GlobalKey<NavigatorState>? get navigatorKey => alice.getNavigatorKey();
}

final dioProvider = DioProvider();
