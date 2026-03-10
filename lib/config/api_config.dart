import 'package:flutter/foundation.dart';

/// Configuración de la API Flask (backend).
///
/// - En **debug** (flutter run -d chrome): usa [developmentBaseUrl] (tu API local).
/// - En **release** (lh-toner.web.app): usa [productionBaseUrl].
///
/// Para que el login funcione en lh-toner.web.app, [productionBaseUrl] debe ser
/// una URL HTTPS (ej. tu API con ngrok o desplegada). Si aún no tenés HTTPS,
/// dejamos la misma URL local; el login solo funcionará cuando corras la app
/// en local (flutter run -d chrome).
class ApiConfig {
  ApiConfig._();

  /// URL de la API en producción (lh-toner.web.app). Debe ser HTTPS.
  static const String productionBaseUrl = 'http://192.168.1.225:5000';

  /// URL de la API en desarrollo (local).
  static const String developmentBaseUrl = 'http://192.168.1.225:5000';

  /// URL base según el modo (sin barra final).
  static String get baseUrl => kReleaseMode ? productionBaseUrl : developmentBaseUrl;

  static const int timeoutSeconds = 15;
}