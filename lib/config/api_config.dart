import 'package:flutter/foundation.dart';

/// Configuración de la API FastAPI (backend).
///
/// - En **debug** (flutter run -d chrome): usa [developmentBaseUrl] (tu API local).
/// - En **release** (p. ej. Firebase Hosting): usa [productionBaseUrl].
///
/// Para que el login funcione en producción, [productionBaseUrl] debe ser
/// una URL HTTPS (ej. tu API con ngrok o desplegada). Si aún no tenés HTTPS,
/// dejamos la misma URL local; el login solo funcionará cuando corras la app
/// en local (flutter run -d chrome).
class ApiConfig {
  ApiConfig._();

  /// URL de la API en producción. Debe ser HTTPS si sirve la app por HTTPS.
  static const String productionBaseUrl = 'http://192.168.1.178:8000';

  /// URL de la API en desarrollo (flutter run en el mismo PC que la API).
  static const String developmentBaseUrl = 'http://localhost:8000';

  /// URL base según el modo (sin barra final).
  static String get baseUrl => kReleaseMode ? productionBaseUrl : developmentBaseUrl;

  static const int timeoutSeconds = 15;
}