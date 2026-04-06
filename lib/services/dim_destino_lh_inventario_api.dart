import 'package:lh_inventario/services/api_client.dart';

/// Fila de [DIM_DESTINO_LH_INVENTARIO]: id_destino, nombre_destino.
class DimDestinoLhInventarioRow {
  const DimDestinoLhInventarioRow({required this.idDestino, required this.nombreDestino});

  final int idDestino;
  final String nombreDestino;

  /// Alias para código que usaba `id` / `nombre`.
  int get id => idDestino;
  String get nombre => nombreDestino;

  factory DimDestinoLhInventarioRow.fromJson(Map<String, dynamic> json) {
    return DimDestinoLhInventarioRow(
      idDestino: (json['id_destino'] ?? json['destino_id'] ?? json['id'] ?? 0) as int,
      nombreDestino: (json['nombre_destino'] ?? json['nombreDestino'] ?? json['nombre'] ?? '') as String,
    );
  }
}

class DimDestinoLhInventarioApi {
  DimDestinoLhInventarioApi._();

  static const String _path = '/api/dim_destino_lh_inventario';

  static Future<List<DimDestinoLhInventarioRow>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['destinos'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => DimDestinoLhInventarioRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((d) => d.idDestino != 0 && d.nombreDestino.isNotEmpty)
        .toList();
  }

  static String _norm(String s) => s.trim().toLowerCase();

  /// Destino sugerido para entradas de inventario: «Almacén», «Stock», «Depósito», etc.
  /// Si no hay coincidencia por nombre, devuelve el primer destino de la lista.
  /// Si la lista está vacía, devuelve `null`.
  static int? idPreferidoParaEntradaInventario(Iterable<DimDestinoLhInventarioRow> destinos) {
    final list = destinos.toList();
    if (list.isEmpty) return null;
    int? porNombre(bool Function(String n) ok) {
      for (final d in list) {
        final n = _norm(d.nombreDestino);
        if (ok(n)) return d.idDestino;
      }
      return null;
    }
    return porNombre((n) => n == 'almacén' || n == 'almacen') ??
        porNombre((n) => n == 'stock') ??
        porNombre((n) => n == 'depósito' || n == 'deposito') ??
        list.first.idDestino;
  }

  /// Para "Añadir stock": destino fijo "oficina central" (oculto en UI). Fallback: primer destino.
  static int? idParaOficinaCentral(Iterable<DimDestinoLhInventarioRow> destinos) {
    final list = destinos.toList();
    if (list.isEmpty) return null;
    for (final d in list) {
      final n = _norm(d.nombreDestino);
      if (n == 'oficina central' || n.contains('oficina central')) return d.idDestino;
    }
    return list.first.idDestino;
  }
}
