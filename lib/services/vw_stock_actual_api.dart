import 'package:lh_tonner/services/api_client.dart';

/// Una fila de la vista SQL [vw_stock_actual] (stock = suma ENTRADA - SALIDA).
class VwStockActualRow {
  const VwStockActualRow({
    required this.idProducto,
    required this.stockActual,
    this.nombreProducto,
    this.nombreCategoria,
  });

  final int idProducto;
  final int stockActual;
  final String? nombreProducto;
  final String? nombreCategoria;

  String get displayNombre => nombreProducto ?? 'Producto #$idProducto';

  factory VwStockActualRow.fromJson(Map<String, dynamic> json) {
    final rawStock = json['stock_actual'] ?? json['stockActual'] ?? json['stock'] ?? 0;
    int stock = 0;
    if (rawStock is int) {
      stock = rawStock;
    } else if (rawStock is num) {
      stock = rawStock.toInt();
    }
    return VwStockActualRow(
      idProducto: (json['producto_id'] ?? json['id_producto'] ?? json['id'] ?? 0) as int,
      stockActual: stock,
      nombreProducto: (json['producto'] ?? json['nombre_producto'] ?? json['nombreProducto'] ?? json['nombre']) as String?,
      nombreCategoria: (json['nombre_categoria'] ?? json['nombreCategoria'] ?? json['categoria']) as String?,
    );
  }
}

class VwStockActualApi {
  VwStockActualApi._();

  static const String _path = '/api/vw_stock_actual';

  /// Lista vacía + [errorCarga] si el GET falla (401, red, etc.).
  static Future<({List<VwStockActualRow> items, String? errorCarga})> listarConEstado() async {
    final res = await ApiClient.get(_path);
    if (!res.ok) {
      return (
        items: <VwStockActualRow>[],
        errorCarga: res.message ?? 'Error al cargar stock (${res.statusCode ?? '?'})',
      );
    }
    if (res.data == null) {
      return (items: <VwStockActualRow>[], errorCarga: null);
    }
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['stock'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) {
      return (items: <VwStockActualRow>[], errorCarga: null);
    }
    final items = list
        .map((e) => VwStockActualRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (items: items, errorCarga: null);
  }

  static Future<List<VwStockActualRow>> listar() async {
    final r = await listarConEstado();
    return r.items;
  }
}
