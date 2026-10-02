// Base URLs, endpoints, and headers.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConstants {
  static String get baseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:5000/api';
}
