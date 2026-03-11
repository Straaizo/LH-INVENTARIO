import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/services/products_api.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<Producto> productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    final lista = await ProductsApi.listar();
    if (mounted) setState(() {
      productos = lista;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    Map<String, List<Producto>> agrupados = {};

    for (var p in productos) {
      agrupados.putIfAbsent(p.categoria, () => []);
      agrupados[p.categoria]!.add(p);
    }

    return Column(
      children: [
        // HEADER //
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: isMobile

          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                   Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 24,
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
                      onPressed: () {
                       _mostrarFormularioProducto();
                      },
                      icon: Icon(Icons.add_outlined,
                      color: Colors.white),
                      label: Text("Agregar",
                      style: TextStyle(
                        color: Colors.white,
                        ),
                      ),
                      ),
                    ),
                  ],                  
                ),
              ],
            )

              // VERSION DE PC //
            : Row(
              children: [

                Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                
                const Spacer(),

                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                    ),
                  onPressed: () {
                    _mostrarFormularioProducto();
                  },
                  icon: Icon(Icons.add_outlined, color: Colors.white),
                  label: Text(
                    "Agregar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
        ),


        // LISTA DE LOS PRODUCTOS //

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
                      List<Producto> listaProductos = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Row(
                              children: [
                                const Icon(Icons.sell_outlined,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Text(
                                  categoria,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...listaProductos.map((producto) {
                            return ListTile(
                              leading: const Icon(
                                Icons.print_outlined,
                                color: Colors.greenAccent,
                              ),
                              title: Text(
                                producto.nombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.white70),
                                    onPressed: () =>
                                        _confirmarEliminar(producto),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: Colors.white70),
                                    onPressed: () =>
                                        _mostrarFormularioProducto(
                                            editarProducto: producto),
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

  void _confirmarEliminar(Producto producto) {
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
              final res = await ProductsApi.eliminar(producto.idProductos);
              if (mounted) {
                if (res.ok) _cargarProductos();
                else ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res.message ?? 'Error al eliminar')),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioProducto({Producto? editarProducto}) {
    final esEdicion = editarProducto != null;
    final nombreController = TextEditingController(text: editarProducto?.nombre ?? '');
    String? categoriaSeleccionada = editarProducto?.categoria;
    String? nombreError;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      esEdicion ? 'Editar Producto' : 'Agregar Producto',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      hint: const Text("Seleccionar categoría"),
                      items: const [
                        DropdownMenuItem(value: "Tóner", child: Text("Tóner")),
                        DropdownMenuItem(value: "Tambor", child: Text("Tambor")),
                      ],
                      onChanged: (value) {
                        setStateDialog(() => categoriaSeleccionada = value);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nombreController,
                      onChanged: (_) => setStateDialog(() => nombreError = null),
                      decoration: InputDecoration(
                        labelText: "Nombre del producto",
                        errorText: nombreError == 'El producto ya existe'
                            ? '\u200B'
                            : nombreError,
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
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.red[700],
                              size: 20,
                            ),
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
                            child: const Text("Cancelar"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final nombre = nombreController.text.trim();
                              final categoria = categoriaSeleccionada ?? "Tóner";
                              if (nombre.isEmpty) {
                                setStateDialog(() => nombreError = 'Ingrese el nombre del producto');
                                return;
                              }
                              if (esEdicion) {
                                final yaExiste = await ProductsApi.existeNombre(
                                    nombre, excluirId: editarProducto.idProductos);
                                if (yaExiste) {
                                  setStateDialog(() => nombreError = 'El producto ya existe');
                                  return;
                                }
                                final res = await ProductsApi.actualizar(
                                    editarProducto.idProductos, nombre, categoria);
                                if (!mounted) return;
                                if (res.ok) {
                                  Navigator.pop(dialogContext);
                                  _cargarProductos();
                                } else {
                                  final msg = res.message ?? '';
                                  final esAuth = res.message?.toLowerCase().contains('authorization') == true ||
                                      res.message?.contains('401') == true;
                                  setStateDialog(() => nombreError =
                                      esAuth ? 'Sesión expirada o no autorizado. Inicie sesión de nuevo.' : msg);
                                }
                              } else {
                                final yaExiste = await ProductsApi.existeNombre(nombre);
                                if (yaExiste) {
                                  setStateDialog(() => nombreError =  'El producto ya existe');
                                  return;
                                }
                                final res = await ProductsApi.crear(nombre, categoria);
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
                                      msg.contains('401') || msg.contains('Missing');
                                  setStateDialog(() => nombreError =
                                      esAuth ? 'Sesión expirada o no autorizado. Inicie sesión de nuevo.' : msg);
                                }
                              }
                            },
                            child: const Text("Guardar"),
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