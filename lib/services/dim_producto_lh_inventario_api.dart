import 'package:lh_inventario/services/api_client.dart';

/// Fila de [DIM_PRODUCTO_LH_INVENTARIO].
class DimProductoLhInventario {
  const DimProductoLhInventario({
    required this.idProducto,
    required this.nombreProducto,
    required this.nombreCategoria,
    this.idCategoria,
  });

  final int idProducto;
  final String nombreProducto;
  final String nombreCategoria;
  final int? idCategoria;

  String get nombre => nombreProducto;
  String get categoria => nombreCategoria;

  factory DimProductoLhInventario.fromJson(Map<String, dynamic> json) {
    return DimProductoLhInventario(
      idProducto: (json['id_producto'] ?? json['id_productos'] ?? json['id'] ?? 0) as int,
      nombreProducto: (json['nombre_producto'] ?? json['nombre'] ?? '') as String,
      nombreCategoria: (json['nombre_categoria'] ?? json['categoria'] ?? '') as String,
      idCategoria: (json['id_categoria'] ?? json['categoria_id']) as int?,
    );
  }
}

class DimProductoLhInventarioApi {
  DimProductoLhInventarioApi._();

  static const String _path = '/api/dim_producto_lh_inventario';

  static Future<List<DimProductoLhInventario>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['productos'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => DimProductoLhInventario.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Contrato recomendado: **`nombre_producto` + `id_categoria`** (del GET categorías).
  static Future<({bool ok, String? message, DimProductoLhInventario? producto})> crear({
    required String nombreProducto,
    required int idCategoria,
  }) async {
    final res = await ApiClient.post(_path, {
      'nombre_producto': nombreProducto.trim(),
      'id_categoria': idCategoria,
    });
    if (res.ok) {
      DimProductoLhInventario? creado;
      if (res.data is Map) {
        final m = Map<String, dynamic>.from(res.data as Map);
        final raw = m['producto'] ?? m['data'] ?? m;
        if (raw is Map) {
          creado = DimProductoLhInventario.fromJson(Map<String, dynamic>.from(raw));
        }
      }
      return (ok: true, message: null, producto: creado);
    }
    return (ok: false, message: res.message ?? 'Error al crear el producto', producto: null);
  }

  static Future<({bool ok, String? message})> actualizar({
    required int idProducto,
    required String nombreProducto,
    required int idCategoria,
  }) async {
    final res = await ApiClient.put('$_path/$idProducto', {
      'nombre_producto': nombreProducto.trim(),
      'id_categoria': idCategoria,
    });
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al actualizar');
  }

  static Future<({bool ok, String? message})> eliminar(int idProducto) async {
    final res = await ApiClient.delete('$_path/$idProducto');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }

  static Future<bool> existeNombre(String nombre, {int? excluirId}) async {
    final lista = await listar();
    final n = nombre.trim().toLowerCase();
    for (final p in lista) {
      if (p.nombreProducto.toLowerCase() == n && p.idProducto != (excluirId ?? -1)) {
        return true;
      }
    }
    return false;
  }
}
