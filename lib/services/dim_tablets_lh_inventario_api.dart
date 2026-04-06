import 'api_client.dart';

int? _parseIntTab(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class DimTabletLhInventario {
  final int idTablet;
  final String codigoTablet;
  final String estado;
  final String marca;
  final String modelo;
  final String capacidad;
  final String fechaEntrega;
  final String responsable;

  const DimTabletLhInventario({
    required this.idTablet,
    required this.codigoTablet,
    required this.estado,
    required this.marca,
    required this.modelo,
    required this.capacidad,
    required this.fechaEntrega,
    required this.responsable,
  });

  factory DimTabletLhInventario.fromJson(Map<String, dynamic> j) {
    String s(String key) => (j[key] ?? '').toString();
    return DimTabletLhInventario(
      idTablet: _parseIntTab(j['id_tablet'] ?? j['id']) ?? 0,
      codigoTablet: s('codigo_tablet'),
      estado: s('estado'),
      marca: s('marca'),
      modelo: s('modelo'),
      capacidad: s('capacidad'),
      fechaEntrega: s('fecha_entrega'),
      responsable: s('responsable'),
    );
  }

  Map<String, dynamic> toJson() => {
        'codigo_tablet': codigoTablet,
        'estado': estado,
        'marca': marca,
        'modelo': modelo,
        'capacidad': capacidad,
        'fecha_entrega': fechaEntrega,
        'responsable': responsable,
      };
}

class DimTabletsLhInventarioApi {
  static const String _path = '/api/dim_tablets_lh_inventario';

  static Future<List<DimTabletLhInventario>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      list = (res.data as Map)['data'] as List?;
    }
    if (list == null) return [];
    return list
        .whereType<Map>()
        .map((e) => DimTabletLhInventario.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({bool ok, String? message, int? id})> crear(
      DimTabletLhInventario t) async {
    final res = await ApiClient.post(_path, t.toJson());
    if (res.ok) {
      int? newId;
      if (res.data is Map) {
        final m = res.data as Map;
        newId = _parseIntTab(m['id_tablet'] ?? m['id']);
      }
      return (ok: true, message: null, id: newId);
    }
    return (ok: false, message: res.message ?? 'Error al crear', id: null);
  }

  static Future<({bool ok, String? message})> actualizar(
      int id, Map<String, dynamic> campos) async {
    final res = await ApiClient.put('$_path/$id', campos);
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al actualizar');
  }

  static Future<({bool ok, String? message})> eliminar(int id) async {
    final res = await ApiClient.delete('$_path/$id');
    if (res.ok) return (ok: true, message: null);
    return (ok: false, message: res.message ?? 'Error al eliminar');
  }
}
