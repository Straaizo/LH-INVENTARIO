import 'api_client.dart';

int? _parseIntImp(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class DimImpresoraLhInventario {
  final int idImpresora;
  final String estado;
  final String ubicacion;
  final String impresora;
  final String conexion;
  final String fecha;
  final String responsable;

  const DimImpresoraLhInventario({
    required this.idImpresora,
    required this.estado,
    required this.ubicacion,
    required this.impresora,
    required this.conexion,
    required this.fecha,
    required this.responsable,
  });

  factory DimImpresoraLhInventario.fromJson(Map<String, dynamic> j) {
    String s(String key) => (j[key] ?? '').toString();
    return DimImpresoraLhInventario(
      idImpresora: _parseIntImp(j['id_impresora'] ?? j['id']) ?? 0,
      estado: s('estado'),
      ubicacion: s('ubicacion'),
      impresora: s('impresora'),
      conexion: s('conexion'),
      fecha: s('fecha'),
      responsable: s('responsable'),
    );
  }

  Map<String, dynamic> toJson() => {
        'estado': estado,
        'ubicacion': ubicacion,
        'impresora': impresora,
        'conexion': conexion,
        'fecha': fecha,
        'responsable': responsable,
      };
}

class DimImpresorasLhInventarioApi {
  static const String _path = '/api/dim_impresoras_lh_inventario';

  static Future<List<DimImpresoraLhInventario>> listar() async {
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
        .map((e) => DimImpresoraLhInventario.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({bool ok, String? message, int? id})> crear(
      DimImpresoraLhInventario imp) async {
    final res = await ApiClient.post(_path, imp.toJson());
    if (res.ok) {
      int? newId;
      if (res.data is Map) {
        final m = res.data as Map;
        newId = _parseIntImp(m['id_impresora'] ?? m['id']);
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
