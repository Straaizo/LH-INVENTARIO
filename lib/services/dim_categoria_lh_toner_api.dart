import 'package:lh_tonner/services/api_client.dart';

/// Fila de [DIM_CATEGORIA_LH_TONER]: id_categoria, nombre_categoria.
class DimCategoriaLhToner {
  const DimCategoriaLhToner({required this.idCategoria, required this.nombreCategoria});

  final int idCategoria;
  final String nombreCategoria;

  factory DimCategoriaLhToner.fromJson(Map<String, dynamic> json) {
    return DimCategoriaLhToner(
      idCategoria: (json['id_categoria'] ?? json['id'] ?? 0) as int,
      nombreCategoria: (json['nombre_categoria'] ?? json['nombre'] ?? '') as String,
    );
  }
}

class DimCategoriaLhTonerApi {
  DimCategoriaLhTonerApi._();

  static const String _path = '/api/dim_categoria_lh_toner';

  static Future<List<DimCategoriaLhToner>> listar() async {
    final res = await ApiClient.get(_path);
    if (!res.ok || res.data == null) return [];
    List? list;
    if (res.data is List) {
      list = res.data as List;
    } else if (res.data is Map) {
      final m = res.data as Map;
      list = (m['data'] ?? m['categorias'] ?? m['items'] ?? m['results']) as List?;
    }
    if (list == null) return [];
    return list
        .map((e) => DimCategoriaLhToner.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => c.idCategoria != 0)
        .toList();
  }
}
