import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/services/dim_categoria_lh_toner_api.dart';
import 'package:lh_tonner/services/dim_producto_lh_toner_api.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<DimProductoLhToner> productos = [];
  List<DimCategoriaLhToner> categorias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final lista = await DimCategoriaLhTonerApi.listar();
    if (mounted) {
      setState(() => categorias = lista);
    }
  }

  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    final lista = await DimProductoLhTonerApi.listar();
    if (mounted) {
      setState(() {
        productos = lista;
        _cargando = false;
      });
    }
  }

  int? _idCategoriaInicial(DimProductoLhToner? editar) {
    if (editar == null) return categorias.isNotEmpty ? categorias.first.idCategoria : null;
    if (editar.idCategoria != null) {
      final existe = categorias.any((c) => c.idCategoria == editar.idCategoria);
      if (existe) return editar.idCategoria;
    }
    final nom = editar.nombreCategoria.trim().toLowerCase();
    for (final c in categorias) {
      if (c.nombreCategoria.trim().toLowerCase() == nom) return c.idCategoria;
    }
    return categorias.isNotEmpty ? categorias.first.idCategoria : null;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    Map<String, List<DimProductoLhToner>> agrupados = {};

    for (var p in productos) {
      agrupados.putIfAbsent(p.categoria, () => []);
      agrupados[p.categoria]!.add(p);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se registran los productos disponibles.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
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
                            onPressed: () => _mostrarFormularioProducto(),
                            icon: const Icon(Icons.add_outlined, color: Colors.white),
                            label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Productos',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Se registran los productos disponibles.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _mostrarFormularioProducto(),
                      icon: const Icon(Icons.add_outlined, color: Colors.white),
                      label: const Text('Agregar', style: TextStyle(color: Colors.white)),
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
                : ListView(
                    children: agrupados.entries.map((entry) {
                      String categoria = entry.key;
                      List<DimProductoLhToner> listaProductos = entry.value;

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
                          ...listaProductos.map((producto) {
                            return ListTile(
                              leading: const Icon(Icons.print_outlined, color: Colors.greenAccent),
                              title: Text(
                                producto.nombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                    onPressed: () => _confirmarEliminar(producto),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                                    onPressed: () => _mostrarFormularioProducto(editarProducto: producto),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  void _confirmarEliminar(DimProductoLhToner producto) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await DimProductoLhTonerApi.eliminar(producto.idProducto);
              if (mounted) {
                if (res.ok) {
                  _cargarProductos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message ?? 'Error al eliminar')),
                  );
                }
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioProducto({DimProductoLhToner? editarProducto}) {
    final esEdicion = editarProducto != null;
    final nombreController = TextEditingController(text: editarProducto?.nombre ?? '');
    int? idCategoriaSeleccionada = _idCategoriaInicial(editarProducto);
    String? nombreError;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      esEdicion ? 'Editar producto' : 'Agregar producto',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      value: idCategoriaSeleccionada,
                      hint: Text(
                        categorias.isEmpty
                            ? 'Cargando categorías…'
                            : 'Seleccionar categoría (id_categoria)',
                      ),
                      items: categorias
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.idCategoria,
                              child: Text(c.nombreCategoria),
                            ),
                          )
                          .toList(),
                      onChanged: categorias.isEmpty
                          ? null
                          : (value) {
                              setStateDialog(() => idCategoriaSeleccionada = value);
                            },
                    ),
                    if (categorias.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No hay categorías. Cree filas en DIM_CATEGORIA_LH_TONER o cargue GET /api/dim_categoria_lh_toner.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nombreController,
                      onChanged: (_) => setStateDialog(() => nombreError = null),
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        errorText: nombreError == 'El producto ya existe' ? '\u200B' : nombreError,
                        errorStyle: TextStyle(
                          color: Colors.red[700],
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontSize: 13,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                        ),
                      ),
                    ),
                    if (nombreError == 'El producto ya existe')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_outlined, color: Colors.red[700], size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'El producto ya existe',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 13,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 25),
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
                              final nombre = nombreController.text.trim();
                              final idCat = idCategoriaSeleccionada;
                              if (nombre.isEmpty) {
                                setStateDialog(() => nombreError = 'Ingrese el nombre del producto');
                                return;
                              }
                              if (idCat == null) {
                                setStateDialog(
                                  () => nombreError = 'Seleccione una categoría (id_categoria)',
                                );
                                return;
                              }
                              if (esEdicion) {
                                final yaExiste = await DimProductoLhTonerApi.existeNombre(
                                  nombre,
                                  excluirId: editarProducto.idProducto,
                                );
                                if (yaExiste) {
                                  setStateDialog(() => nombreError = 'El producto ya existe');
                                  return;
                                }
                                final res = await DimProductoLhTonerApi.actualizar(
                                  idProducto: editarProducto.idProducto,
                                  nombreProducto: nombre,
                                  idCategoria: idCat,
                                );
                                if (!mounted) return;
                                if (res.ok) {
                                  Navigator.pop(dialogContext);
                                  _cargarProductos();
                                } else {
                                  final msg = res.message ?? '';
                                  final esAuth = msg.toLowerCase().contains('authorization') ||
                                      msg.contains('401');
                                  setStateDialog(() => nombreError =
                                      esAuth ? 'Sesión expirada o no autorizado. Inicie sesión de nuevo.' : msg);
                                }
                              } else {
                                final yaExiste = await DimProductoLhTonerApi.existeNombre(nombre);
                                if (yaExiste) {
                                  setStateDialog(() => nombreError = 'El producto ya existe');
                                  return;
                                }
                                final res = await DimProductoLhTonerApi.crear(
                                  nombreProducto: nombre,
                                  idCategoria: idCat,
                                );
                                if (!mounted) return;
                                if (res.ok) {
                                  if (res.producto != null) {
                                    setState(() => productos = [...productos, res.producto!]);
                                  }
                                  Navigator.pop(dialogContext);
                                  _cargarProductos();
                                } else {
                                  final msg = res.message ?? '';
                                  final esAuth = msg.toLowerCase().contains('authorization') ||
                                      msg.contains('401') ||
                                      msg.contains('Missing');
                                  setStateDialog(() => nombreError =
                                      esAuth ? 'Sesión expirada o no autorizado. Inicie sesión de nuevo.' : msg);
                                }
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
      },
    );
  }
}
