import 'api_client.dart';

int? _parseIntCel(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class DimCelularLhInventario {
  final int idCelular;
  final String numero;
  final String estado;
  final String tipoCelular;
  final String compania;
  final String marca;
  final String modelo;
  final String imei;
  final String fechaEntrega;
  final String responsable;

  const DimCelularLhInventario({
    required this.idCelular,
    required this.numero,
    required this.estado,
    required this.tipoCelular,
    required this.compania,
    required this.marca,
    required this.modelo,
    required this.imei,
    required this.fechaEntrega,
    required this.responsable,
  });

  factory DimCelularLhInventario.fromJson(Map<String, dynamic> j) {
    String s(String key) => (j[key] ?? '').toString();
    return DimCelularLhInventario(
      idCelular: _parseIntCel(j['id_celular'] ?? j['id']) ?? 0,
      numero: s('numero'),
      estado: s('estado'),
      tipoCelular: s('tipo_celular'),
      compania: s('compania'),
      marca: s('marca'),
      modelo: s('modelo'),
      imei: s('imei'),
      fechaEntrega: s('fecha_entrega'),
      responsable: s('responsable'),
    );
  }

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'estado': estado,
        'tipo_celular': tipoCelular,
        'compania': compania,
        'marca': marca,
        'modelo': modelo,
        'imei': imei,
        'fecha_entrega': fechaEntrega,
        'responsable': responsable,
      };
}

class DimCelularesLhInventarioApi {
  static const String _path = '/api/dim_celulares_lh_inventario';

  static Future<List<DimCelularLhInventario>> listar() async {
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
        .map((e) => DimCelularLhInventario.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({bool ok, String? message, int? id})> crear(
      DimCelularLhInventario celular) async {
    final res = await ApiClient.post(_path, celular.toJson());
    if (res.ok) {
      int? newId;
      if (res.data is Map) {
        final m = res.data as Map;
        newId = (m['id_celular'] ?? m['id']) as int?;
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
