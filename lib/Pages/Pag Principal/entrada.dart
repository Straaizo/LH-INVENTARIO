import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lh_inventario/utils/descarga_csv_stub.dart'
    if (dart.library.html) 'package:lh_inventario/utils/descarga_csv_web.dart' as descarga_csv;
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_inventario/services/dim_destino_lh_inventario_api.dart';
import 'package:lh_inventario/services/dim_tipo_movimiento_lh_inventario_api.dart';
import 'package:lh_inventario/services/dim_usuario_lh_inventario_api.dart';
import 'package:lh_inventario/services/dim_producto_lh_inventario_api.dart';
import 'package:lh_inventario/services/fact_movimientos_lh_inventario_api.dart';

class EntradaPage extends StatefulWidget {
  const EntradaPage({super.key});

  @override
  State<EntradaPage> createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
  List<FactMovimientoSalidaItem> entradas = [];
  bool _cargando = true;
  /// `id_usuario` → nombre para mostrar (desde `GET /api/dim_usuario_lh_inventario`).
  Map<int, String> _nombresPorUsuarioId = {};

  /// Token para forzar recarga del formulario al reabrir el modal.
  int _formRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _cargarEntradas();
  }

  Future<void> _cargarEntradas() async {
    setState(() => _cargando = true);
    final lista = await FactMovimientosLhInventarioApi.listarEntradas();
    final mapaNombres = await DimUsuarioLhInventarioApi.mapaNombresParaMostrarPorId();
    if (mounted) {
      setState(() {
        entradas = lista;
        _nombresPorUsuarioId = mapaNombres;
        _cargando = false;
      });
    }
  }

  /// Nombre para mostrar (columna `nombre` en dim_usuario); si no hay mapa, el login.
  String _nombreUsuarioMovimiento(FactMovimientoSalidaItem e) {
    final id = e.idUsuario;
    if (id != null) {
      final n = _nombresPorUsuarioId[id];
      if (n != null && n.isNotEmpty) return n;
    }
    return (e.usuarioNombre ?? '').trim();
  }

  /// Productos (dim) + destinos + id tipo "Entrada" para POST de stock.
  static Future<List<Object?>> _cargarDatosFormularioEntrada() async {
    final tipos = await DimTipoMovimientoLhInventarioApi.listar();
    final idEntrada = DimTipoMovimientoLhInventarioApi.idParaEntrada(tipos);
    final destinos = await DimDestinoLhInventarioApi.listar();
    final productos = await DimProductoLhInventarioApi.listar();
    return [productos, destinos, idEntrada];
  }

  /// Agrupa entradas por **momento exacto** (fecha+hora+segundo) y destino.
  /// Así cada registro en horarios distintos tiene su fila; un mismo envío con varios productos sigue agrupado.
  List<List<FactMovimientoSalidaItem>> _entradasAgrupadas() {
    final Map<String, List<FactMovimientoSalidaItem>> grupos = {};
    for (final e in entradas) {
      final key = '${_claveAgrupacionMomento(e.fecha)}|${e.nombreDestino}';
      grupos.putIfAbsent(key, () => []).add(e);
    }
    final lista = grupos.values.toList();
    lista.sort((a, b) {
      final fa = a.first.fecha;
      final fb = b.first.fecha;
      final da = DateTime.tryParse(fa);
      final db = DateTime.tryParse(fb);
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });
    return lista;
  }

  String _claveAgrupacionMomento(String fecha) {
    if (fecha.isEmpty) return '';
    final d = DateTime.tryParse(fecha);
    if (d == null) return fecha;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  /// Escapa un campo CSV (usa punto y coma como separador).
  String _csvCampo(String? valor) {
    if (valor == null) return '';
    if (valor.contains(';') || valor.contains('"') || valor.contains('\n')) {
      return '"${valor.replaceAll('"', '""')}"';
    }
    return valor;
  }

  Future<void> _descargarExcel() async {
    if (entradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay entradas para exportar')),
      );
      return;
    }
    final sb = StringBuffer();
    sb.write('\uFEFF'); // BOM UTF-8 para que Excel abra bien acentos
    sb.writeln('Fecha y hora;Destino;Producto;Cantidad;Registrado por');
    final ordenadas = List<FactMovimientoSalidaItem>.from(entradas)
      ..sort((a, b) {
        final da = DateTime.tryParse(a.fecha);
        final db = DateTime.tryParse(b.fecha);
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
    for (final e in ordenadas) {
      sb.writeln(
        '${_csvCampo(_formatearFechahora(e.fecha))};'
        '${_csvCampo(e.nombreDestino)};'
        '${_csvCampo(e.productoNombre)};'
        '${e.cantidad};'
        '${_csvCampo(_nombreUsuarioMovimiento(e))}',
      );
    }
    final csv = sb.toString();
    final bytes = Uint8List.fromList(utf8.encode(csv));
    final nombre = 'entradas_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.csv';

    if (kIsWeb) {
      descarga_csv.descargarCsvWeb(bytes, nombre);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descarga iniciada (revisa la carpeta de descargas)')),
        );
      }
      return;
    }

    final path = await FilePicker.platform.saveFile(
      fileName: nombre,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (mounted) {
      if (path != null && path.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guardado: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportado (revisa la carpeta de descargas)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrada',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Se registran las entradas de stock.',
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
                                  backgroundColor: Colors.green[900],
                                ),
                                onPressed: _descargarExcel,
                                icon: const Icon(Icons.download_outlined, color: Colors.white),
                                label: const Text('Excel', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _mostrarFormularioEntrada(),
                                icon: const Icon(Icons.add_outlined, color: Colors.white),
                                label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )

                    // VERSION DE PC //
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Entrada',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Se registran las entradas de stock.',
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
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
                          onPressed: _descargarExcel,
                          icon: const Icon(Icons.download_outlined, color: Colors.white),
                          label: const Text('Excel', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _mostrarFormularioEntrada(),
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
                    : ListView.builder(
                        itemCount: _entradasAgrupadas().length,
                        itemBuilder: (context, index) {
                          final grupo = _entradasAgrupadas()[index];
                          final primera = grupo.first;
                          final textoProductos = grupo.map((e) => e.displayProducto).join(' - ');
                          final subtitulo = '${primera.nombreDestino} - $textoProductos';
                          final nombreUsuario = _nombreUsuarioMovimiento(primera);
                          return ListTile(
                            title: Text(
                              _formatearFechahora(primera.fecha),
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  subtitulo,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (nombreUsuario.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Registrado por: $nombreUsuario',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 22),
                                  onPressed: () => _mostrarEditarGrupo(grupo),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                                  onPressed: () => _confirmarEliminarGrupo(grupo),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Fecha y hora para listado y export (ej. 11/3/2026 14:30).
  String _formatearFechahora(String fecha) {
    if (fecha.isEmpty) return fecha;
    try {
      final d = DateTime.tryParse(fecha);
      if (d != null) {
        final h = d.hour.toString().padLeft(2, '0');
        final m = d.minute.toString().padLeft(2, '0');
        return '${d.day}/${d.month}/${d.year} $h:$m';
      }
    } catch (_) {}
    return fecha;
  }

  void _mostrarFormularioEntrada() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: FutureBuilder<List<Object?>>(
            key: ValueKey(_formRefreshToken),
            future: _EntradaPageState._cargarDatosFormularioEntrada(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando productos, destinos y tipos de movimiento...'),
                    ],
                  ),
                );
              }
              final productos = (snapshot.data != null && snapshot.data!.isNotEmpty)
                  ? snapshot.data![0] as List<DimProductoLhInventario>
                  : <DimProductoLhInventario>[];
              final destinos = (snapshot.data != null && snapshot.data!.length > 1)
                  ? snapshot.data![1] as List<DimDestinoLhInventarioRow>
                  : <DimDestinoLhInventarioRow>[];
              final idTipoEntrada = (snapshot.data != null && snapshot.data!.length > 2)
                  ? snapshot.data![2] as int?
                  : null;
              if (productos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar entrada',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('No hay productos. Agregue productos en la sección Productos.'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              if (destinos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar entrada',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('No hay destinos (dim_destino). La base exige id_destino en cada movimiento.'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              if (idTipoEntrada == null) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar entrada',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No se encontró el tipo de movimiento "Entrada" en '
                        'GET /api/dim_tipo_movimiento_lh_inventario.',
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              return _FormularioEntrada(
                productos: productos,
                destinos: destinos,
                idTipoMovEntrada: idTipoEntrada,
                onExito: () {
                  _cargarEntradas();
                  setState(() => _formRefreshToken++);
                  Navigator.pop(dialogContext);
                },
                onCancelar: () => Navigator.pop(dialogContext),
                dialogContext: dialogContext,
              );
            },
          ),
        );
      },
    );
  }

  void _mostrarEditarEntrada(FactMovimientoSalidaItem item) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: FutureBuilder<List<Object?>>(
            key: ValueKey(_formRefreshToken),
            future: _EntradaPageState._cargarDatosFormularioEntrada(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando...'),
                    ],
                  ),
                );
              }
              final productos = (snapshot.data != null && snapshot.data!.isNotEmpty)
                  ? snapshot.data![0] as List<DimProductoLhInventario>
                  : <DimProductoLhInventario>[];
              final destinos = (snapshot.data != null && snapshot.data!.length > 1)
                  ? snapshot.data![1] as List<DimDestinoLhInventarioRow>
                  : <DimDestinoLhInventarioRow>[];
              final idTipoEntrada = (snapshot.data != null && snapshot.data!.length > 2)
                  ? snapshot.data![2] as int?
                  : null;
              if (productos.isEmpty || destinos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No hay datos de productos o destinos.'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              return _FormularioEntrada(
                productos: productos,
                destinos: destinos,
                idTipoMovEntrada: idTipoEntrada,
                movimientoExistente: item,
                onExito: () {
                  _cargarEntradas();
                  setState(() => _formRefreshToken++);
                  Navigator.pop(dialogContext);
                },
                onCancelar: () => Navigator.pop(dialogContext),
                dialogContext: dialogContext,
              );
            },
          ),
        );
      },
    );
  }

  void _confirmarEliminar(FactMovimientoSalidaItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: Text(
          '¿Eliminar entrada en "${item.nombreDestino}" - ${item.displayProducto}? Se actualizará el stock en inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await FactMovimientosLhInventarioApi.eliminar(item.idMovimiento);
              if (!mounted) return;
              if (res.ok) {
                _cargarEntradas();
                setState(() => _formRefreshToken++);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res.message ?? 'Error al eliminar')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarEditarGrupo(List<FactMovimientoSalidaItem> grupo) {
    if (grupo.length == 1) {
      _mostrarEditarEntrada(grupo.first);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar entrada'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Esta fila tiene varios productos. Elija cuál editar:'),
              const SizedBox(height: 12),
              ...grupo.map((item) => ListTile(
                    title: Text(item.displayProducto),
                    trailing: const Icon(Icons.edit_outlined, size: 20),
                    onTap: () {
                      Navigator.pop(ctx);
                      _mostrarEditarEntrada(item);
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarGrupo(List<FactMovimientoSalidaItem> grupo) {
    if (grupo.length == 1) {
      _confirmarEliminar(grupo.first);
      return;
    }
    final primera = grupo.first;
    final textoLinea = grupo.map((e) => e.displayProducto).join(' - ');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: Text(
          '¿Eliminar entrada en "${primera.nombreDestino} - $textoLinea"? Se actualizará el stock en inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              for (final item in grupo) {
                await FactMovimientosLhInventarioApi.eliminar(item.idMovimiento);
                if (!mounted) return;
              }
              _cargarEntradas();
              setState(() => _formRefreshToken++);
            },
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }
}

class _FormularioEntrada extends StatefulWidget {
  const _FormularioEntrada({
    required this.productos,
    required this.destinos,
    this.idTipoMovEntrada,
    required this.onExito,
    required this.onCancelar,
    required this.dialogContext,
    this.movimientoExistente,
  });

  final List<DimProductoLhInventario> productos;
  final List<DimDestinoLhInventarioRow> destinos;
  /// Obligatorio para registrar nueva entrada; puede ser null al editar (solo PUT).
  final int? idTipoMovEntrada;
  final VoidCallback onExito;
  final VoidCallback onCancelar;
  final BuildContext dialogContext;
  final FactMovimientoSalidaItem? movimientoExistente;

  @override
  State<_FormularioEntrada> createState() => _FormularioEntradaState();
}

class _FilaProductoEntrada {
  _FilaProductoEntrada({this.idProducto}) : cantidadController = TextEditingController();
  int? idProducto;
  final TextEditingController cantidadController;
}

class _FormularioEntradaState extends State<_FormularioEntrada> {
  int? _destinoIdSeleccionado;
  final List<_FilaProductoEntrada> _filasProducto = [];
  String? _errorMsg;
  int? _errorFilaIndex;

  @override
  void initState() {
    super.initState();
    if (widget.movimientoExistente != null) {
      final e = widget.movimientoExistente!;
      _destinoIdSeleccionado = e.destinoId;
      if (_destinoIdSeleccionado == null) {
        for (final d in widget.destinos) {
          if (d.nombre == e.nombreDestino) {
            _destinoIdSeleccionado = d.id;
            break;
          }
        }
      }
      _destinoIdSeleccionado ??= widget.destinos.isNotEmpty ? widget.destinos.first.id : null;
      _filasProducto.add(_FilaProductoEntrada(idProducto: e.idProducto)
        ..cantidadController.text = e.cantidad.toString());
    } else {
      final idOc = DimDestinoLhInventarioApi.idParaOficinaCentral(widget.destinos);
      _destinoIdSeleccionado =
          idOc ?? (widget.destinos.isNotEmpty ? widget.destinos.first.id : null);
      if (widget.productos.isNotEmpty) {
        _filasProducto.add(_FilaProductoEntrada(idProducto: widget.productos.first.idProducto));
      } else {
        _filasProducto.add(_FilaProductoEntrada());
      }
    }
  }

  @override
  void dispose() {
    for (final f in _filasProducto) {
      f.cantidadController.dispose();
    }
    super.dispose();
  }

  void _agregarOtraFila() {
    setState(() {
      final id = widget.productos.isNotEmpty ? widget.productos.first.idProducto : null;
      _filasProducto.add(_FilaProductoEntrada(idProducto: id));
      _errorMsg = null;
      _errorFilaIndex = null;
    });
  }

  void _quitarFila(int index) {
    if (_filasProducto.length <= 1) return;
    setState(() {
      _filasProducto[index].cantidadController.dispose();
      _filasProducto.removeAt(index);
      _errorMsg = null;
      _errorFilaIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.movimientoExistente != null;
    final maxDialogW = min(500.0, MediaQuery.sizeOf(context).width - 24);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxDialogW),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                esEdicion ? 'Editar entrada' : 'Registrar entrada',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _destinoIdSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Destino (almacén / oficina central)',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Seleccionar destino'),
                items: widget.destinos
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.nombre, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _destinoIdSeleccionado = value),
              ),
              const SizedBox(height: 20),

              const Text('Productos', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              ...List.generate(_filasProducto.length, (index) {
                final fila = _filasProducto[index];
                final tieneError = _errorFilaIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: fila.idProducto,
                          decoration: InputDecoration(
                            labelText: 'Producto',
                            border: const OutlineInputBorder(),
                            errorText: tieneError && _errorMsg != null ? '' : null,
                          ),
                          hint: const Text('Seleccionar'),
                          items: widget.productos
                              .map(
                                (p) => DropdownMenuItem<int>(
                                  value: p.idProducto,
                                  child: Text(
                                    '${p.nombre} (${p.categoria})',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            fila.idProducto = value;
                            _errorMsg = null;
                            _errorFilaIndex = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: fila.cantidadController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {
                            _errorMsg = null;
                            _errorFilaIndex = null;
                          }),
                          decoration: InputDecoration(
                            labelText: 'Cant.',
                            border: const OutlineInputBorder(),
                            errorText: tieneError ? _errorMsg : null,
                            errorStyle: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      if (_filasProducto.length > 1)
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            onPressed: () => _quitarFila(index),
                            tooltip: 'Quitar fila',
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                );
              }),

              if (!esEdicion)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _agregarOtraFila,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar otro producto'),
                  ),
                ),

              if (_errorMsg != null && _errorFilaIndex == null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: Colors.red[700], size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: TextStyle(color: Colors.red[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _guardar(context),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar(BuildContext context) async {
    setState(() {
      _errorMsg = null;
      _errorFilaIndex = null;
    });

    if (_destinoIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione destino')),
      );
      return;
    }

    if (widget.movimientoExistente != null) {
      final fila = _filasProducto.single;
      if (fila.idProducto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un producto')),
        );
        return;
      }
      final cantidad = int.tryParse(fila.cantidadController.text.trim()) ?? 0;
      if (cantidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese una cantidad válida')),
        );
        return;
      }
      final res = await FactMovimientosLhInventarioApi.actualizarSalida(
        widget.movimientoExistente!.idMovimiento,
        idDestino: _destinoIdSeleccionado,
        idProducto: fila.idProducto,
        cantidad: cantidad,
      );
      if (!mounted) return;
      if (res.ok) {
        widget.onExito();
      } else {
        if (res.errorStock != null) {
          setState(() {
            _errorMsg = '${res.errorStock!.message}. '
                'Stock disponible: ${res.errorStock!.stockDisponible ?? "?"}. '
                'Solicitado: ${res.errorStock!.cantidadSolicitada ?? "?"}';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Error al actualizar')),
          );
        }
      }
      return;
    }

    for (var i = 0; i < _filasProducto.length; i++) {
      final fila = _filasProducto[i];
      if (fila.idProducto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione producto en todas las filas')),
        );
        return;
      }
      final cantidad = int.tryParse(fila.cantidadController.text.trim()) ?? 0;
      if (cantidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese cantidad válida en todas las filas')),
        );
        return;
      }
    }

    final idTipo = widget.idTipoMovEntrada;
    if (idTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo de movimiento "Entrada" no disponible. Recargue o revise la API.'),
        ),
      );
      return;
    }

    for (var i = 0; i < _filasProducto.length; i++) {
      final fila = _filasProducto[i];
      final cantidad = int.tryParse(fila.cantidadController.text.trim()) ?? 0;
      final res = await FactMovimientosLhInventarioApi.entrada(
        idProducto: fila.idProducto!,
        cantidad: cantidad,
        idDestino: _destinoIdSeleccionado!,
        idTipoMov: idTipo,
      );
      if (!mounted) return;
      if (!res.ok) {
        setState(() {
          _errorFilaIndex = i;
          _errorMsg = res.message ?? 'Error al registrar entrada';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Error al registrar entrada')),
        );
        return;
      }
    }
    widget.onExito();
  }
}
