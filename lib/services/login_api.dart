import 'package:lh_tonner/services/api_client.dart';

/// Respuesta del endpoint de login.
class LoginResult {
  const LoginResult({required this.ok, this.nombre, this.message, this.token});

  final bool ok;
  final String? nombre;
  final String? message;
  final String? token;
}

/// Llama al blueprint usuarios_lh_toner para validar credenciales.
class LoginApi {
  LoginApi._();

  static const String _path = '/api/usuarios_lh_toner/login';

  /// Valida email y contraseña en la API. Devuelve [LoginResult] con nombre si es correcto.
  static Future<LoginResult> validar(String email, String password) async {
    final res = await ApiClient.post(_path, {
      'email': email.trim(),
      'password': password,
    });

    if (res.ok && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      // Acepta ok: true, success: true, o message de éxito ("Login correcto", etc.)
      final bool esExito = data['ok'] == true ||
          data['success'] == true ||
          (data['message'] is String &&
              (data['message'] as String).toLowerCase().contains('correcto'));
      final String? nombre = data['nombre'] as String? ??
          data['name'] as String? ??
          data['nombre_usuario'] as String?;
      final String? token = data['access_token'] as String? ??
          data['token'] as String? ??
          data['token_access'] as String?;

      if (esExito) {
        return LoginResult(
          ok: true,
          nombre: nombre?.trim().isNotEmpty == true ? nombre : 'Usuario',
          token: token,
        );
      }
      return LoginResult(
        ok: false,
        message: data['message'] as String? ?? 'Error al iniciar sesión',
      );
    }

    final msg = res.message ?? 'Error de conexión con el servidor';
    return LoginResult(ok: false, message: msg);
  }

  /// Obtiene el nombre del usuario desde la API (tabla) por email.
  /// Endpoint esperado: GET /api/usuarios_lh_toner/perfil?email=xxx
  /// Respuesta: { "nombre": "..." } o { "nombre_usuario": "..." }
  static Future<String> obtenerNombreUsuario(String email) async {
    if (email.trim().isEmpty) return 'Usuario';
    final res = await ApiClient.get(
      '/api/usuarios_lh_toner/perfil?email=${Uri.encodeComponent(email.trim())}',
    );
    if (res.ok && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final nombre = data['nombre'] as String? ??
          data['name'] as String? ??
          data['nombre_usuario'] as String?;
      if (nombre != null && nombre.trim().isNotEmpty) {
        return nombre.trim();
      }
    }
    return 'Usuario';
  }
}
