import 'package:lh_inventario/services/api_client.dart';

/// Fila de [DIM_TIPO_MOVIMIENTO_LH_INVENTARIO]: id_tipo_movimiento, nombre_movimiento.
class DimTipoMovimientoLhInventarioRow {
  const DimTipoMovimientoLhInventarioRow({
    required this.idTipoMovimiento,
    required this.nombreMovimiento,
  });

  final int idTipoMovimiento;
  final String nombreMovimiento;

  factory DimTipoMovimientoLhInventarioRow.fromJson(Map<String, dynamic> json) {
    return DimTipoMovimientoLhInventarioRow(
      idTipoMovimiento:
          (json['id_tipo_movimiento'] ?? json['id_tipo_mov'] ?? json['id'] ?? 0) as int,
      nombreMovimiento:
          (json['nombre_movimiento'] ?? json['nombreMovimiento'] ?? json['nombre'] ?? '') as String,
    );
  }
}

class DimTipoMovimientoLhInventarioApi {
  DimTipoMovimientoLhInventarioApi._();

  static const String _path = '/api/dim_tipo_movimiento_lh_inventario';

  static Future<List<DimTipoMovimientoLhInventarioRow>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['tipos'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => DimTipoMovimientoLhInventarioRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((t) => t.idTipoMovimiento != 0)
        .toList();
  }

  static String _norm(String s) => s.trim().toLowerCase();

  /// Ítem cuyo [nombre_movimiento] es "Entrada" (sin depender de mayúsculas).
  static int? idParaEntrada(Iterable<DimTipoMovimientoLhInventarioRow> tipos) {
    for (final t in tipos) {
      if (_norm(t.nombreMovimiento) == 'entrada') return t.idTipoMovimiento;
    }
    return null;
  }

  /// Ítem cuyo [nombre_movimiento] es "Salida" (sin depender de mayúsculas).
  static int? idParaSalida(Iterable<DimTipoMovimientoLhInventarioRow> tipos) {
    for (final t in tipos) {
      if (_norm(t.nombreMovimiento) == 'salida') return t.idTipoMovimiento;
    }
    return null;
  }
}
