import 'api_client.dart';

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

// ── Modelo ────────────────────────────────────────────────────────────────────

class DimEquipoLhInventario {
  final int idEquipos;
  final String codigoEquipo;
  final String estado;
  final String antivirus;
  final String ubicacion;
  final String tipo;
  final String marca;
  final String modelo;
  final String procesador;
  final String ram;
  final String discoDuro;
  final String sistemaOperativo;
  final String office;
  final String numeroSerie;
  final String fechaRevision;
  final int? fkIdUsuario;
  final String responsable;
  final String usuarioNombre;
  final String usuarioCorreo;

  const DimEquipoLhInventario({
    required this.idEquipos,
    required this.codigoEquipo,
    required this.estado,
    required this.antivirus,
    required this.ubicacion,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.procesador,
    required this.ram,
    required this.discoDuro,
    required this.sistemaOperativo,
    required this.office,
    required this.numeroSerie,
    required this.fechaRevision,
    this.fkIdUsuario,
    required this.responsable,
    required this.usuarioNombre,
    required this.usuarioCorreo,
  });

  factory DimEquipoLhInventario.fromJson(Map<String, dynamic> j) {
    String s(String key, [String fallback = '']) =>
        (j[key] ?? fallback).toString();
    return DimEquipoLhInventario(
      idEquipos: _parseInt(j['id_equipos'] ?? j['id']) ?? 0,
      codigoEquipo: s('codigo_equipo', s('codigo')),
      estado: s('estado'),
      antivirus: s('antivirus'),
      ubicacion: s('ubicacion'),
      tipo: s('tipo'),
      marca: s('marca'),
      modelo: s('modelo'),
      procesador: s('procesador'),
      ram: s('ram'),
      discoDuro: s('disco_duro'),
      sistemaOperativo: s('sistema_operativo'),
      office: s('office'),
      numeroSerie: s('numero_serie'),
      fechaRevision: s('fecha_revision'),
      fkIdUsuario: _parseInt(j['fk_id_usuario']),
      responsable: s('responsable'),
      usuarioNombre: s('usuario_nombre'),
      usuarioCorreo: s('usuario_correo'),
    );
  }

  Map<String, dynamic> toJson() => {
        'codigo_equipo': codigoEquipo,
        'estado': estado,
        'antivirus': antivirus,
        'ubicacion': ubicacion,
        'tipo': tipo,
        'marca': marca,
        'modelo': modelo,
        'procesador': procesador,
        'ram': ram,
        'disco_duro': discoDuro,
        'sistema_operativo': sistemaOperativo,
        'office': office,
        'numero_serie': numeroSerie,
        'fecha_revision': fechaRevision,
        'responsable': responsable,
        if (fkIdUsuario != null) 'fk_id_usuario': fkIdUsuario,
      };
}

// ── Servicio ──────────────────────────────────────────────────────────────────

class DimEquiposLhInventarioApi {
  static const String _path = '/api/dim_equipos_lh_inventario';

  static Future<List<DimEquipoLhInventario>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['equipos'] ?? m['items']) as List?;
    }
    if (list == null) return [];
    return list
        .whereType<Map>()
        .map((e) => DimEquipoLhInventario.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({bool ok, String? message, int? id})> crear(
      DimEquipoLhInventario equipo) async {
    final res = await ApiClient.post(_path, equipo.toJson());
    if (res.ok) {
      int? newId;
      if (res.data is Map) {
        final m = res.data as Map;
        newId = _parseInt(m['id_equipos'] ?? m['id']);
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
