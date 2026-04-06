import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_inventario/services/dim_producto_lh_inventario_api.dart';
import 'package:lh_inventario/services/vw_stock_actual_api.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  /// Una fila por producto: stock agregado desde `GET /api/vw_stock_actual` → `data`.
  List<VwStockActualRow> inventario = [];
  /// Misma fuente que la pantalla Productos: categoría por `id_producto` desde dim_producto.
  Map<int, String> _categoriaPorIdProducto = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    setState(() => _cargando = true);
    final stockFuture = VwStockActualApi.listarConEstado();
    final productosFuture = DimProductoLhInventarioApi.listar();
    final r = await stockFuture;
    final productos = await productosFuture;
    final mapCat = <int, String>{};
    for (final p in productos) {
      final c = p.nombreCategoria.trim();
      if (p.idProducto != 0 && c.isNotEmpty) {
        mapCat[p.idProducto] = c;
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      inventario = r.items;
      _categoriaPorIdProducto = mapCat;
      _cargando = false;
    });
    if (r.errorCarga != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.errorCarga!)),
      );
    }
  }

  String _categoriaParaItem(VwStockActualRow item) {
    final desdeDim = _categoriaPorIdProducto[item.idProducto]?.trim();
    if (desdeDim != null && desdeDim.isNotEmpty) return desdeDim;
    final desdeVista = item.nombreCategoria?.trim();
    if (desdeVista != null && desdeVista.isNotEmpty) return desdeVista;
    return 'Sin categoría';
  }

  /// Agrupado por categoría (igual criterio que Productos: dim_producto).
  Widget _buildListaStockAgrupada() {
    if (inventario.isEmpty) {
      return Center(
        child: Text(
          'No hay datos en la vista de stock (vw_stock_actual)',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
        ),
      );
    }
    final Map<String, List<VwStockActualRow>> agrupados = {};
    for (final item in inventario) {
      agrupados.putIfAbsent(_categoriaParaItem(item), () => []).add(item);
    }
    final claves = agrupados.keys.toList()
      ..sort((a, b) {
        if (a == 'Sin categoría') return 1;
        if (b == 'Sin categoría') return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return ListView(
      children: claves.map((categoria) {
        final items = agrupados[categoria]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  const Icon(Icons.sell_outlined, color: Colors.orange),
                  const SizedBox(width: 10),
                  Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) {
              final stock = item.stockActual;
              final bajoStock = stock <= 5;
              return ListTile(
                leading: const Icon(Icons.print_outlined, color: Colors.greenAccent),
                title: Text(
                  item.displayNombre,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      bajoStock ? Icons.warning_outlined : Icons.check_outlined,
                      color: bajoStock ? Colors.amber : Colors.greenAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stock.toString(),
                      style: TextStyle(
                        color: bajoStock ? Colors.amber : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
          
          bool isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              // HEADER RESPONSIVO //
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: isMobile

                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El stock se registra en entrada.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
                // VERSION DE ESCRITORIO / PC ///
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Inventario",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'El stock se registra en entrada.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              
              Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _cargando
                        ? const Center(child: CircularProgressIndicator(color: Colors.white70))
                        : _buildListaStockAgrupada(),
                  ),
                ),
            ],
          );
        },
    );
  }
}