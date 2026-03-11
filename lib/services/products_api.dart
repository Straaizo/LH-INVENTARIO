import 'package:lh_tonner/services/api_client.dart';

/// Modelo de producto (tabla PRODUCTOS_LH_TONER).
class Producto {
  const Producto({
    required this.idProductos,
    required this.nombre,
    required this.categoria,
  });

  final int idProductos;
  final String nombre;
  final String categoria;

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProductos: (json['id_productos'] ?? json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? json['subject'] ?? '') as String,
      categoria: (json['categoria'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_productos': idProductos,
        'nombre': nombre,
        'categoria': categoria,
      };
}

/// API para PRODUCTOS_LH_TONER (listar, crear, actualizar, eliminar).
class ProductsApi {
  ProductsApi._();

  static const String _path = '/api/productos_lh_toner';

  /// Lista todos los productos.
  static Future<List<Producto>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['productos'] ?? m['data'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => Producto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Crea un producto. Si el backend responde que ya existe, [message] tendrá el texto de error.
  /// Si el backend devuelve el producto creado, se devuelve en [producto] para mostrarlo en la lista.
  static Future<({bool ok, String? message, Producto? producto})> crear(
      String nombre, String categoria) async {
    final res = await ApiClient.post(_path, {
      'nombre': nombre.trim(),
      'subject': nombre.trim(),
      'categoria': categoria.trim(),
    });
    if (res.ok) {
      Producto? creado;
      if (res.data is Map) {
        final m = Map<String, dynamic>.from(res.data as Map);
        final raw = m['producto'] ?? m['data'] ?? m;
        if (raw is Map) {
          creado = Producto.fromJson(Map<String, dynamic>.from(raw));
        }
      }
      return (ok: true, message: null, producto: creado);
    }
    final msg = res.message ?? 'Error al crear el producto';
    return (ok: false, message: msg, producto: null);
  }

  /// Actualiza un producto por id.
  static Future<({bool ok, String? message})> actualizar(
      int id, String nombre, String categoria) async {
    final n = nombre.trim();
    final res = await ApiClient.put('$_path/$id', {
      'nombre': n,
      'subject': n,
      'categoria': categoria.trim(),
    });
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al actualizar');
  }

  /// Elimina un producto por id.
  static Future<({bool ok, String? message})> eliminar(int id) async {
    final res = await ApiClient.delete('$_path/$id');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }

  /// Comprueba si ya existe un producto con ese nombre (ignorando mayúsculas).
  /// Útil para validar antes de guardar. Si [excluirId] se pasa, se excluye ese id (para editar).
  static Future<bool> existeNombre(String nombre,
      {int? excluirId}) async {
    final lista = await listar();
    final n = nombre.trim().toLowerCase();
    for (final p in lista) {
      if (p.nombre.toLowerCase() == n && p.idProductos != (excluirId ?? -1)) {
        return true;
      }
    }
    return false;
  }
}
