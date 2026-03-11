import 'package:lh_tonner/services/api_client.dart';

/// Modelo de entrega (tabla ENTREGAR_LH_TONER + inventario_nombre, usuario_nombre para la vista).
class EntregaItem {
  const EntregaItem({
    required this.idEntrega,
    required this.nombreSucursal,
    required this.fecha,
    required this.cantidad,
    required this.fkIdInventario,
    this.fkIdUsuario,
    this.inventarioNombre,
    this.usuarioNombre,
  });

  final int idEntrega;
  final String nombreSucursal;
  final String fecha;
  final int cantidad;
  final int fkIdInventario;
  final int? fkIdUsuario;
  final String? inventarioNombre;
  /// Nombre del usuario que registró la entrega (solo para mostrar en lista).
  final String? usuarioNombre;

  String get displayProducto => inventarioNombre != null && inventarioNombre!.isNotEmpty
      ? '$inventarioNombre ($cantidad)'
      : 'Producto #$fkIdInventario ($cantidad)';

  factory EntregaItem.fromJson(Map<String, dynamic> json) {
    return EntregaItem(
      idEntrega: (json['id_ENTREGAR_LH_TONER'] ?? json['id_entregar_lh_toner'] ?? json['id'] ?? 0) as int,
      nombreSucursal: (json['nombre_sucursal'] ?? json['nombreSucursal'] ?? '') as String,
      fecha: (json['fecha'] ?? '') as String,
      cantidad: (json['cantidad'] ?? 0) as int,
      fkIdInventario: (json['FK_ID_INVENTARIO_LH_TONER'] ?? json['fk_id_inventario_lh_toner'] ?? json['id_inventario'] ?? 0) as int,
      fkIdUsuario: (json['FK_ID_USUARIO_LH_TONER'] ?? json['fk_id_usuario_lh_toner']) as int?,
      inventarioNombre: (json['inventario_nombre'] ?? json['inventarioNombre']) as String?,
      usuarioNombre: (json['usuario_nombre'] ?? json['usuarioNombre'] ?? json['usuario']) as String?,
    );
  }
}

/// Resultado al crear entrega cuando hay error 400 (cantidad excede stock).
class EntregaErrorStock {
  const EntregaErrorStock({
    required this.message,
    this.stockDisponible,
    this.cantidadSolicitada,
  });
  final String message;
  final int? stockDisponible;
  final int? cantidadSolicitada;
}

/// API para ENTREGAR_LH_TONER (listar, crear, actualizar, eliminar).
class EntregarApi {
  EntregarApi._();

  static const String _path = '/api/entregar_lh_toner';

  /// Lista entregas (incluye inventario_nombre para la vista).
  static Future<List<EntregaItem>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['entregas'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => EntregaItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Crea una entrega. Descuenta del inventario. Si cantidad > stock, 400 con datos.
  static Future<({bool ok, String? message, EntregaErrorStock? errorStock})> crear({
    required String nombreSucursal,
    required int idInventario,
    required int cantidad,
    String? fecha,
  }) async {
    final body = <String, dynamic>{
      'nombre_sucursal': nombreSucursal.trim(),
      'FK_ID_INVENTARIO_LH_TONER': idInventario,
      'id_inventario': idInventario,
      'cantidad': cantidad,
    };
    if (fecha != null && fecha.trim().isNotEmpty) body['fecha'] = fecha.trim();

    final res = await ApiClient.post(_path, body);
    if (res.ok) return (ok: true, message: null, errorStock: null);

    EntregaErrorStock? errorStock;
    if (res.statusCode == 400 && res.data is Map) {
      final d = res.data as Map;
      errorStock = EntregaErrorStock(
        message: res.message ?? 'La cantidad excede el stock disponible',
        stockDisponible: (d['stock_disponible'] ?? d['stockDisponible']) as int?,
        cantidadSolicitada: (d['cantidad_solicitada'] ?? d['cantidadSolicitada']) as int?,
      );
    }
    return (ok: false, message: res.message, errorStock: errorStock);
  }

  /// Actualiza una entrega (ajusta stock: restaura y vuelve a descontar).
  static Future<({bool ok, String? message, EntregaErrorStock? errorStock})> actualizar(
    int idEntrega, {
    String? nombreSucursal,
    int? idInventario,
    int? cantidad,
    String? fecha,
  }) async {
    final body = <String, dynamic>{};
    if (nombreSucursal != null) body['nombre_sucursal'] = nombreSucursal.trim();
    if (idInventario != null) {
      body['FK_ID_INVENTARIO_LH_TONER'] = idInventario;
      body['id_inventario'] = idInventario;
    }
    if (cantidad != null) body['cantidad'] = cantidad;
    if (fecha != null) body['fecha'] = fecha;

    final res = await ApiClient.put('$_path/$idEntrega', body.isEmpty ? null : body);
    if (res.ok) return (ok: true, message: null, errorStock: null);

    EntregaErrorStock? errorStock;
    if (res.statusCode == 400 && res.data is Map) {
      final d = res.data as Map;
      errorStock = EntregaErrorStock(
        message: res.message ?? 'La cantidad excede el stock disponible',
        stockDisponible: (d['stock_disponible'] ?? d['stockDisponible']) as int?,
        cantidadSolicitada: (d['cantidad_solicitada'] ?? d['cantidadSolicitada']) as int?,
      );
    }
    return (ok: false, message: res.message, errorStock: errorStock);
  }

  /// Elimina una entrega (restaura stock en inventario).
  static Future<({bool ok, String? message})> eliminar(int idEntrega) async {
    final res = await ApiClient.delete('$_path/$idEntrega');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }
}
