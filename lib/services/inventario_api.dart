import 'package:lh_tonner/services/api_client.dart';

/// Modelo de ítem de inventario (tabla INVENTARIO_LH_TONER + datos del producto).
class InventarioItem {
  const InventarioItem({
    required this.idInventario,
    required this.cantidad,
    required this.fkIdProductos,
    this.nombre,
    this.productoNombre,
    this.productoCategoria,
  });

  final int idInventario;
  final int cantidad;
  final int fkIdProductos;
  final String? nombre;
  final String? productoNombre;
  final String? productoCategoria;

  /// Nombre para mostrar en lista (producto_nombre del JOIN o nombre del ítem).
  String get displayNombre => productoNombre ?? nombre ?? 'Sin nombre';

  factory InventarioItem.fromJson(Map<String, dynamic> json) {
    return InventarioItem(
      idInventario: (json['id_inventario'] ?? json['id'] ?? 0) as int,
      cantidad: (json['cantidad'] ?? 0) as int,
      fkIdProductos: (json['fk_ID_PRODUCTOS_LH_TONER'] ?? json['id_producto'] ?? json['fk_id_productos_lh_toner'] ?? 0) as int,
      nombre: json['nombre'] as String?,
      productoNombre: (json['producto_nombre'] ?? json['productoNombre']) as String?,
      productoCategoria: (json['producto_categoria'] ?? json['productoCategoria']) as String?,
    );
  }
}

/// API para INVENTARIO_LH_TONER (listar, añadir stock, actualizar, eliminar).
class InventarioApi {
  InventarioApi._();

  static const String _path = '/api/inventario_lh_toner';

  /// Lista el inventario (incluye producto_nombre, producto_categoria para la vista).
  static Future<List<InventarioItem>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['inventario'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => InventarioItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Anade stock. Body: fk_ID_PRODUCTOS_LH_TONER (o id_producto) + cantidad.
  static Future<({bool ok, String? message})> anadirStock(int idProducto, int cantidad) async {
    final res = await ApiClient.post(_path, {
      'fk_ID_PRODUCTOS_LH_TONER': idProducto,
      'id_producto': idProducto,
      'cantidad': cantidad,
    });
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al anadir stock');
  }

  /// Actualiza un registro (cantidad y/o producto).
  static Future<({bool ok, String? message})> actualizar(
      int idInventario, {int? cantidad, int? fkIdProducto}) async {
    final body = <String, dynamic>{};
    if (cantidad != null) body['cantidad'] = cantidad;
    if (fkIdProducto != null) {
      body['fk_ID_PRODUCTOS_LH_TONER'] = fkIdProducto;
      body['id_producto'] = fkIdProducto;
    }
    final res = await ApiClient.put('$_path/$idInventario', body.isEmpty ? null : body);
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al actualizar');
  }

  /// Elimina un registro de inventario.
  static Future<({bool ok, String? message})> eliminar(int idInventario) async {
    final res = await ApiClient.delete('$_path/$idInventario');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }
}
