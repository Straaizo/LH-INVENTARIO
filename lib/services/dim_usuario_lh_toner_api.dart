import 'package:lh_tonner/services/api_client.dart';

/// Respuesta del endpoint de login (usuario en [dim_usuario_lh_toner]).
class LoginResult {
  const LoginResult({
    required this.ok,
    this.nombre,
    this.correo,
    this.message,
    this.token,
    this.errorCode,
  });

  final bool ok;
  /// Preferir `usuario.nombre` del JSON; si no hay, `nombre_usuario`.
  final String? nombre;
  /// Correo real del usuario (para GET perfil si hiciera falta).
  final String? correo;
  final String? message;
  final String? token;
  /// Códigos de la API: USER_NOT_FOUND, WRONG_PASSWORD, INVALID_IDENT, INVALID_EMAIL, …
  final String? errorCode;
}

/// Autenticación y perfil ligados a [dim_usuario_lh_toner].
class DimUsuarioLhTonerApi {
  DimUsuarioLhTonerApi._();

  static const String _pathLogin = '/api_lh_toner/login';
  static const String _pathMe = '/api/dim_usuario_lh_toner/me';
  /// Listado completo (JWT): incluye `nombre` para mostrar y `nombre_usuario` (login).
  static const String _pathListar = '/api/dim_usuario_lh_toner';
  static const String _pathPerfilBase = '/api/usuarios_lh_toner/perfil';

  static String? _nombreDesdeUsuarioMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    // API: `nombre` = nombre para mostrar (ej. Enzo); `nombre_usuario` = login (ej. esabattini).
    final n = m['nombre'] ?? m['nombre_usuario'] ?? m['name'];
    if (n is String && n.trim().isNotEmpty) return n.trim();
    return null;
  }

  /// Login: **`contrasenia`** / **`password`** + identificador en correo/email **o** usuario/username/nombre_usuario.
  static Future<LoginResult> validar(String identificador, String contrasenia) async {
    final id = identificador.trim();
    final res = await ApiClient.post(_pathLogin, {
      'correo': id,
      'email': id,
      'usuario': id,
      'username': id,
      'nombre_usuario': id,
      'contrasenia': contrasenia,
      'password': contrasenia,
    });

    if (res.ok && res.data is Map) {
      final data = Map<String, dynamic>.from(res.data as Map);
      final bool esExito = data['ok'] == true ||
          data['success'] == true ||
          (data['message'] is String &&
              (data['message'] as String).toLowerCase().contains('correcto'));
      Map<String, dynamic>? usuarioMap;
      final u = data['usuario'] ?? data['user'];
      if (u is Map) {
        usuarioMap = Map<String, dynamic>.from(u);
      }
      final String? correoUsuario = usuarioMap?['correo'] as String?;
      final String? nombre = data['nombre'] as String? ??
          data['name'] as String? ??
          _nombreDesdeUsuarioMap(usuarioMap) ??
          data['nombre_usuario'] as String?;
      final String? token = data['access_token'] as String? ??
          data['token'] as String? ??
          data['token_access'] as String?;

      if (esExito) {
        return LoginResult(
          ok: true,
          nombre: nombre?.trim().isNotEmpty == true ? nombre!.trim() : 'Usuario',
          correo: correoUsuario?.trim().isNotEmpty == true ? correoUsuario!.trim() : null,
          token: token,
        );
      }
      final errTxt = data['message'] as String? ??
          data['error'] as String? ??
          'Error al iniciar sesión';
      return LoginResult(
        ok: false,
        message: errTxt.toString(),
        errorCode: _codeDesdeMapa(data),
      );
    }

    return _loginResultDesdeErrorHttp(res);
  }

  static String? _codeDesdeMapa(Map<String, dynamic> data) {
    final c = data['code'];
    if (c is String && c.trim().isNotEmpty) return c.trim();
    return null;
  }

  static LoginResult _loginResultDesdeErrorHttp(ApiResponse res) {
    final msg = res.message ?? 'Error de conexión con el servidor';
    final raw = res.data;
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      return LoginResult(
        ok: false,
        message: msg,
        errorCode: _codeDesdeMapa(m),
      );
    }
    return LoginResult(ok: false, message: msg);
  }

  /// Nombre para mostrar en la app.
  ///
  /// 1) Si hay JWT: **`GET /api/dim_usuario_lh_toner/me`** (recomendado en producción).
  /// 2) Si no: **`GET /api/usuarios_lh_toner/perfil?email=`** (también acepta `correo=` en el servidor).
  static Future<String> obtenerNombreUsuario(String email) async {
    if (ApiClient.hasAuthToken) {
      final res = await ApiClient.get(_pathMe);
      if (res.ok && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        final u = data['usuario'] ?? data['user'];
        if (u is Map) {
          final n = _nombreDesdeUsuarioMap(Map<String, dynamic>.from(u));
          if (n != null) return n;
        }
      }
    }

    if (email.trim().isEmpty) return 'Usuario';

    final q = Uri.encodeComponent(email.trim());
    var res = await ApiClient.get('$_pathPerfilBase?email=$q');
    if (!res.ok || res.data is! Map) {
      res = await ApiClient.get('$_pathPerfilBase?correo=$q');
    }
    if (res.ok && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final u = data['usuario'] ?? data['user'];
      if (u is Map) {
        final n = _nombreDesdeUsuarioMap(Map<String, dynamic>.from(u));
        if (n != null) return n;
      }
      final top = data['nombre_usuario'] ?? data['nombre'];
      if (top is String && top.trim().isNotEmpty) return top.trim();
    }
    return 'Usuario';
  }

  /// Mapa `id_usuario` → nombre para mostrar (columna `nombre`; si está vacío, `nombre_usuario`).
  /// Usar en listados (p. ej. entregas) donde el movimiento solo trae login en `nombre_usuario`.
  static Future<Map<int, String>> mapaNombresParaMostrarPorId() async {
    final res = await ApiClient.get(_pathListar);
    final map = <int, String>{};
    if (!res.ok || res.data is! Map) return map;
    final data = res.data as Map<String, dynamic>;
    final list = data['data'];
    if (list is! List) return map;
    for (final e in list) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final rawId = m['id_usuario'] ?? m['id'];
      int? id;
      if (rawId is int) {
        id = rawId;
      } else if (rawId is num) {
        id = rawId.toInt();
      }
      if (id == null) continue;
      final display = _nombreDesdeUsuarioMap(m) ??
          (m['nombre_usuario'] is String ? (m['nombre_usuario'] as String).trim() : null);
      if (display != null && display.isNotEmpty) {
        map[id] = display;
      }
    }
    return map;
  }
}
