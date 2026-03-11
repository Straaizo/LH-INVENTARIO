import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/services/inventario_api.dart';
import 'package:lh_tonner/services/products_api.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<InventarioItem> inventario = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    setState(() => _cargando = true);
    final lista = await InventarioApi.listar();
    if (mounted) setState(() {
      inventario = lista;
      _cargando = false;
    });
  }

  Widget _buildListaInventarioAgrupada() {
    Map<String, List<InventarioItem>> agrupados = {};
    for (var item in inventario) {
      String cat = item.productoCategoria ?? 'Sin categoría';
      agrupados.putIfAbsent(cat, () => []);
      agrupados[cat]!.add(item);
    }
    return ListView(
      children: agrupados.entries.map((entry) {
        String categoria = entry.key;
        List<InventarioItem> items = entry.value;
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
              final stock = item.cantidad;
              bool bajoStock = stock <= 5;
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 22),
                  onPressed: () => _mostrarEditarCantidad(item),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  void _mostrarEditarCantidad(InventarioItem item) {
    final cantidadController = TextEditingController(text: item.cantidad.toString());

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editar cantidad',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.displayNombre,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;
                          if (cantidad < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingrese una cantidad válida')),
                            );
                            return;
                          }
                          final res = await InventarioApi.actualizar(item.idInventario, cantidad: cantidad);
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (res.ok) {
                            _cargarInventario();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.message ?? 'Error al actualizar')),
                            );
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("Stock",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    ),

                    const SizedBox(height: 15),
                    
                     Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _mostrarFormulario,
                            icon: const Icon(Icons.add_outlined, color: Colors.white),
                            label: Text("Agregar",  // ignore: avoid_non_ascii_characters
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                // VERSION DE ESCRITORIO / PC ///
                : Row(
                  children: [
                    Text(
                      "Stock",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _mostrarFormulario,
                      icon: const Icon(Icons.add_outlined, color: Colors.white),
                      label: const Text("Agregar", style: TextStyle(color: Colors.white)),
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
                        : _buildListaInventarioAgrupada(),
                  ),
                ),
            ],
          );
        },
    );
}

void _mostrarFormulario() {
    final stockController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: FutureBuilder<List<Producto>>(
            future: ProductsApi.listar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando productos...'),
                    ],
                  ),
                );
              }
              final productos = snapshot.data ?? [];
              if (productos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Añadir Stock',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('No hay productos. Agregue productos primero.'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              return _FormularioAnadirStock(
                productos: productos,
                stockController: stockController,
                onExito: _cargarInventario,
                onCancelar: () => Navigator.pop(dialogContext),
                dialogContext: dialogContext,
              );
            },
          ),
        );
      },
    );
  }
}

class _FormularioAnadirStock extends StatefulWidget {
  const _FormularioAnadirStock({
    required this.productos,
    required this.stockController,
    required this.onExito,
    required this.onCancelar,
    required this.dialogContext,
  });

  final List<Producto> productos;
  final TextEditingController stockController;
  final VoidCallback onExito;
  final VoidCallback onCancelar;
  final BuildContext dialogContext;

  @override
  State<_FormularioAnadirStock> createState() => _FormularioAnadirStockState();
}

class _FormularioAnadirStockState extends State<_FormularioAnadirStock> {
  int? _idProductoSeleccionado;

  @override
  void initState() {
    super.initState();
    _idProductoSeleccionado = widget.productos.isNotEmpty ? widget.productos.first.idProductos : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Añadir Stock",  // ignore: avoid_non_ascii_characters
            style: TextStyle(
              fontSize: 22,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: _idProductoSeleccionado,
            decoration: const InputDecoration(
              labelText: "Producto",
              border: OutlineInputBorder(),
            ),
            items: widget.productos
                .map((p) => DropdownMenuItem<int>(
                      value: p.idProductos,
                      child: Text('${p.nombre} (${p.categoria})'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _idProductoSeleccionado = value),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Cantidad",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelar,
                  child: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_idProductoSeleccionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Seleccione un producto')),
                      );
                      return;
                    }
                    final cantidad = int.tryParse(widget.stockController.text.trim()) ?? 0;
                    if (cantidad <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingrese una cantidad válida')),
                      );
                      return;
                    }
                    final res = await InventarioApi.anadirStock(_idProductoSeleccionado!, cantidad);
                    if (!mounted) return;
                    if (res.ok) {
                      widget.onExito();
                      Navigator.pop(widget.dialogContext);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res.message ?? 'Error al anadir stock')),
                      );
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}