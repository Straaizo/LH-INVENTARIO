import 'package:lh_tonner/services/api_client.dart';

/// Fila del listado `GET /api/fact_movimientos_lh_toner` → `{ "data": [ ... ] }`.
/// En UI de inventario solo se usan [nombreProducto] y [cantidad].
class FactMovimientoListadoItem {
  const FactMovimientoListadoItem({
    required this.idMovimiento,
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidad,
    this.nombreCategoria = '',
    this.fecha = '',
    this.nombreDestino = '',
    this.nombreMovimiento = '',
    this.idDestino,
    this.idUsuario,
    this.usuarioNombre,
  });

  final int idMovimiento;
  final int idProducto;
  final String nombreProducto;
  final int cantidad;
  /// Para agrupar en Inventario (viene del JOIN dim categoría en el API).
  final String nombreCategoria;
  final String fecha;
  final String nombreDestino;
  final String nombreMovimiento;
  final int? idDestino;
  final int? idUsuario;
  final String? usuarioNombre;

  String get displayNombre =>
      nombreProducto.isNotEmpty ? nombreProducto : 'Producto #$idProducto';

  String get categoriaDisplay =>
      nombreCategoria.trim().isNotEmpty ? nombreCategoria.trim() : 'Sin categoría';

  factory FactMovimientoListadoItem.fromJson(Map<String, dynamic> json) {
    final cant = json['cantidad'];
    int c = 0;
    if (cant is int) {
      c = cant;
    } else if (cant is num) {
      c = cant.toInt();
    }
    final rawFecha = json['fecha'];
    String fechaStr = '';
    if (rawFecha is String) {
      fechaStr = rawFecha;
    } else if (rawFecha != null) {
      fechaStr = rawFecha.toString();
    }
    final rawDest = json['id_destino'] ?? json['destino_id'];
    int? idDest;
    if (rawDest is int) {
      idDest = rawDest;
    } else if (rawDest is num) {
      idDest = rawDest.toInt();
    }
    final rawUsu = json['id_usuario'] ?? json['usuario_id'];
    int? idUsu;
    if (rawUsu is int) {
      idUsu = rawUsu;
    } else if (rawUsu is num) {
      idUsu = rawUsu.toInt();
    }
    final rawIdMov = json['id_movimientos'] ?? json['id_movimiento'] ?? json['id'] ?? 0;
    final rawIdProd = json['id_producto'] ?? json['producto_id'] ?? 0;
    int idMov = 0;
    if (rawIdMov is int) {
      idMov = rawIdMov;
    } else if (rawIdMov is num) {
      idMov = rawIdMov.toInt();
    }
    int idProd = 0;
    if (rawIdProd is int) {
      idProd = rawIdProd;
    } else if (rawIdProd is num) {
      idProd = rawIdProd.toInt();
    }
    return FactMovimientoListadoItem(
      idMovimiento: idMov,
      idProducto: idProd,
      nombreProducto:
          (json['nombre_producto'] ?? json['producto_nombre'] ?? json['producto'] ?? '') as String,
      cantidad: c,
      nombreCategoria:
          (json['nombre_categoria'] ?? json['categoria'] ?? json['nombreCategoria'] ?? '') as String,
      fecha: fechaStr,
      nombreDestino:
          (json['nombre_destino'] ?? json['nombreDestino'] ?? json['nombre_sucursal'] ?? '') as String,
      nombreMovimiento:
          (json['nombre_movimiento'] ?? json['nombreMovimiento'] ?? '') as String,
      idDestino: idDest,
      idUsuario: idUsu,
      usuarioNombre: (json['usuario_nombre'] ?? json['usuarioNombre'] ?? json['nombre_usuario']) as String?,
    );
  }
}

/// Proyección SALIDA desde [FACT_MOVIMIENTOS_LH_TONER] + JOINs.
class FactMovimientoSalidaItem {
  const FactMovimientoSalidaItem({
    required this.idMovimiento,
    required this.nombreDestino,
    required this.fecha,
    required this.cantidad,
    required this.idProducto,
    this.idDestino,
    this.idUsuario,
    this.usuarioNombre,
    this.productoNombre,
  });

  final int idMovimiento;
  final String nombreDestino;
  final String fecha;
  final int cantidad;
  final int idProducto;
  final int? idDestino;
  /// FK a dim_usuario (para resolver nombre para mostrar en el cliente).
  final int? idUsuario;
  /// Login / nombre_usuario tal como viene del listado de movimientos.
  final String? usuarioNombre;
  final String? productoNombre;

  int? get destinoId => idDestino;

  String get displayProducto => productoNombre != null && productoNombre!.isNotEmpty
      ? '$productoNombre ($cantidad)'
      : 'Producto #$idProducto ($cantidad)';

  factory FactMovimientoSalidaItem.fromJson(Map<String, dynamic> json) {
    final rawUsu = json['id_usuario'] ?? json['usuario_id'];
    int? idUsu;
    if (rawUsu is int) {
      idUsu = rawUsu;
    } else if (rawUsu is num) {
      idUsu = rawUsu.toInt();
    }

    return FactMovimientoSalidaItem(
      idMovimiento: (json['id_movimientos'] ?? json['id_movimiento'] ?? json['id_MOVIMIENTO'] ?? json['id'] ?? 0) as int,
      nombreDestino: (json['nombre_destino'] ?? json['nombreDestino'] ?? json['nombre_sucursal'] ?? '') as String,
      fecha: (json['fecha'] ?? '') as String,
      cantidad: (json['cantidad'] ?? 0) as int,
      idProducto: (json['id_producto'] ?? json['producto_id'] ?? 0) as int,
      idDestino: (json['id_destino'] ?? json['destino_id']) as int?,
      idUsuario: idUsu,
      usuarioNombre: (json['usuario_nombre'] ?? json['usuarioNombre'] ?? json['nombre_usuario']) as String?,
      productoNombre: (json['nombre_producto'] ?? json['producto_nombre'] ?? json['productoNombre'] ?? json['producto']) as String?,
    );
  }
}

class FactMovimientoStockError {
  const FactMovimientoStockError({
    required this.message,
    this.stockDisponible,
    this.cantidadSolicitada,
  });
  final String message;
  final int? stockDisponible;
  final int? cantidadSolicitada;
}

/// [FACT_MOVIMIENTOS_LH_TONER] — mismas rutas bajo `/api/fact_movimientos_lh_toner` y `/api/movimientos_lh_toner`.
class FactMovimientosLhTonerApi {
  FactMovimientosLhTonerApi._();

  static const String _path = '/api/fact_movimientos_lh_toner';

  static FactMovimientoStockError? _parseErrorStock(ApiResponse res) {
    if (res.statusCode != 400 || res.data is! Map) return null;
    final d = res.data as Map;
    return FactMovimientoStockError(
      message: res.message ?? 'La cantidad excede el stock disponible',
      stockDisponible: (d['stock_disponible'] ?? d['stockDisponible']) as int?,
      cantidadSolicitada: (d['cantidad_solicitada'] ?? d['cantidadSolicitada']) as int?,
    );
  }

  /// Todos los movimientos del hecho (entradas y salidas). `data` en el JSON.
  static Future<({List<FactMovimientoListadoItem> items, String? errorCarga})> listarMovimientos() async {
    final res = await ApiClient.get(_path);
    if (!res.ok) {
      return (
        items: <FactMovimientoListadoItem>[],
        errorCarga: res.message ??
            'Error al cargar movimientos (${res.statusCode ?? '?'})',
      );
    }
    if (res.data == null) {
      return (items: <FactMovimientoListadoItem>[], errorCarga: null);
    }
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['movimientos'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) {
      return (items: <FactMovimientoListadoItem>[], errorCarga: null);
    }
    final items = list
        .map((e) => FactMovimientoListadoItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (items: items, errorCarga: null);
  }

  static Future<List<FactMovimientoSalidaItem>> listarSalidas() async {
    final res = await ApiClient.get('$_path/salidas');
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['movimientos'] ?? m['salidas'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => FactMovimientoSalidaItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Movimientos cuyo `nombre_movimiento` contiene ENTRADA (filtrado en cliente desde el listado completo).
  static Future<List<FactMovimientoSalidaItem>> listarEntradas() async {
    final r = await listarMovimientos();
    if (r.errorCarga != null) return [];
    final out = <FactMovimientoSalidaItem>[];
    for (final m in r.items) {
      if (!m.nombreMovimiento.toUpperCase().contains('ENTRADA')) continue;
      out.add(
        FactMovimientoSalidaItem(
          idMovimiento: m.idMovimiento,
          nombreDestino: m.nombreDestino,
          fecha: m.fecha,
          cantidad: m.cantidad,
          idProducto: m.idProducto,
          idDestino: m.idDestino,
          idUsuario: m.idUsuario,
          usuarioNombre: m.usuarioNombre,
          productoNombre: m.nombreProducto,
        ),
      );
    }
    return out;
  }

  /// ENTRADA: [idTipoMov] (tipo "Entrada") y [idDestino] obligatorios — la BD suele exigir `id_destino` NOT NULL.
  static Future<({bool ok, String? message})> entrada({
    required int idProducto,
    required int cantidad,
    required int idTipoMov,
    required int idDestino,
  }) async {
    final res = await ApiClient.post(_path, {
      'cantidad': cantidad,
      'id_producto': idProducto,
      'producto_id': idProducto,
      'id_tipo_mov': idTipoMov,
      'tipo_mov_id': idTipoMov,
      'id_destino': idDestino,
      'destino_id': idDestino,
    });
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al registrar entrada');
  }

  /// [idTipoMov] debe venir del dim (tipo "Salida").
  static Future<({bool ok, String? message, FactMovimientoStockError? errorStock})> salida({
    required int idProducto,
    required int cantidad,
    required int idDestino,
    required int idTipoMov,
    String? fecha,
  }) async {
    final body = <String, dynamic>{
      'cantidad': cantidad,
      'id_producto': idProducto,
      'producto_id': idProducto,
      'id_tipo_mov': idTipoMov,
      'tipo_mov_id': idTipoMov,
      'id_destino': idDestino,
      'destino_id': idDestino,
    };
    if (fecha != null && fecha.trim().isNotEmpty) body['fecha'] = fecha.trim();

    final res = await ApiClient.post(_path, body);
    if (res.ok) return (ok: true, message: null, errorStock: null);
    return (ok: false, message: res.message, errorStock: _parseErrorStock(res));
  }

  static Future<({bool ok, String? message})> ajustarStock({
    required int idProducto,
    required int cantidadNueva,
  }) async {
    final res = await ApiClient.post('$_path/ajuste', {
      'id_producto': idProducto,
      'cantidad_nueva': cantidadNueva,
    });
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al ajustar stock');
  }

  static Future<({bool ok, String? message, FactMovimientoStockError? errorStock})> actualizarSalida(
    int idMovimiento, {
    int? idDestino,
    int? idProducto,
    int? cantidad,
    String? fecha,
  }) async {
    final body = <String, dynamic>{};
    if (idDestino != null) body['id_destino'] = idDestino;
    if (idProducto != null) body['id_producto'] = idProducto;
    if (cantidad != null) body['cantidad'] = cantidad;
    if (fecha != null) body['fecha'] = fecha;

    final res = await ApiClient.put('$_path/$idMovimiento', body.isEmpty ? null : body);
    if (res.ok) return (ok: true, message: null, errorStock: null);
    return (ok: false, message: res.message, errorStock: _parseErrorStock(res));
  }

  static Future<({bool ok, String? message})> eliminar(int idMovimiento) async {
    final res = await ApiClient.delete('$_path/$idMovimiento');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }
}
