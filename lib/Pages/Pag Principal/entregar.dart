import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lh_tonner/utils/descarga_csv_stub.dart'
    if (dart.library.html) 'package:lh_tonner/utils/descarga_csv_web.dart' as descarga_csv;
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/services/entregar_api.dart';
import 'package:lh_tonner/services/inventario_api.dart';

class EntregarPage extends StatefulWidget {
  const EntregarPage({super.key});

  @override
  State<EntregarPage> createState() => _EntregarPageState();
}

class _EntregarPageState extends State<EntregarPage> {
  List<EntregaItem> entregas = [];
  bool _cargando = true;

  static const List<String> solicitantes = [
    'Oficina Central',
    'Santa Victoria',
    'Cullipeumo',
    'Hospital',
    'Santa Inés',
    'Maitén',
    'San Manuel',
    'Itahue',
  ];

  @override
  void initState() {
    super.initState();
    _cargarEntregas();
  }

  Future<void> _cargarEntregas() async {
    setState(() => _cargando = true);
    final lista = await EntregarApi.listar();
    if (mounted) {
      setState(() {
        entregas = lista;
        _cargando = false;
      });
    }
  }

  /// Agrupa entregas por fecha (solo dia) y sucursal para mostrar en una sola fila.
  List<List<EntregaItem>> _entregasAgrupadas() {
    final Map<String, List<EntregaItem>> grupos = {};
    for (final e in entregas) {
      final fechaNorm = _fechaParaGrupo(e.fecha);
      final key = '$fechaNorm|${e.nombreSucursal}';
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

  String _fechaParaGrupo(String fecha) {
    if (fecha.isEmpty) return fecha;
    final d = DateTime.tryParse(fecha);
    if (d == null) return fecha;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
    if (entregas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay entregas para exportar')),
      );
      return;
    }
    final sb = StringBuffer();
    sb.write('\uFEFF'); // BOM UTF-8 para que Excel abra bien acentos
    sb.writeln('Fecha y hora;Sucursal;Producto;Cantidad;Entregado por');
    final ordenadas = List<EntregaItem>.from(entregas)
      ..sort((a, b) {
        final da = DateTime.tryParse(a.fecha);
        final db = DateTime.tryParse(b.fecha);
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
    for (final e in ordenadas) {
      sb.writeln(
        '${_csvCampo(_formatearFechahora(e.fecha))};'
        '${_csvCampo(e.nombreSucursal)};'
        '${_csvCampo(e.inventarioNombre)};'
        '${e.cantidad};'
        '${_csvCampo(e.usuarioNombre)}',
      );
    }
    final csv = sb.toString();
    final bytes = Uint8List.fromList(utf8.encode(csv));
    final nombre = 'entregas_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.csv';

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
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entregar',
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
                                onPressed: () => _mostrarFormularioEntregar(),
                                icon: const Icon(Icons.add_outlined, color: Colors.white),
                                label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          'Entregar',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
                          onPressed: _descargarExcel,
                          icon: const Icon(Icons.download_outlined, color: Colors.white),
                          label: const Text('Excel', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _mostrarFormularioEntregar(),
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
                        itemCount: _entregasAgrupadas().length,
                        itemBuilder: (context, index) {
                          final grupo = _entregasAgrupadas()[index];
                          final primera = grupo.first;
                          final textoProductos = grupo.map((e) => e.displayProducto).join(' - ');
                          final subtitulo = '${primera.nombreSucursal} - $textoProductos';
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
                                if (primera.usuarioNombre != null && primera.usuarioNombre!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Entregado por: ${primera.usuarioNombre}',
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

  void _mostrarFormularioEntregar() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: FutureBuilder<List<InventarioItem>>(
            future: InventarioApi.listar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando inventario...'),
                    ],
                  ),
                );
              }
              final inventario = snapshot.data ?? [];
              if (inventario.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar Entrega',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('No hay productos en inventario. Agregue stock primero.'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              return _FormularioEntrega(
                inventario: inventario,
                solicitantes: solicitantes,
                onExito: () {
                  _cargarEntregas();
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

  void _mostrarEditarEntrega(EntregaItem item) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: FutureBuilder<List<InventarioItem>>(
            future: InventarioApi.listar(),
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
              final inventario = snapshot.data ?? [];
              if (inventario.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No hay inventario disponible.'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
              return _FormularioEntrega(
                inventario: inventario,
                solicitantes: solicitantes,
                entregaExistente: item,
                onExito: () {
                  _cargarEntregas();
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

  void _confirmarEliminar(EntregaItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entrega'),
        content: Text(
          '¿Eliminar entrega a "${item.nombreSucursal}" - ${item.displayProducto}? Se restaurará el stock en inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await EntregarApi.eliminar(item.idEntrega);
              if (!mounted) return;
              if (res.ok) {
                _cargarEntregas();
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

  void _mostrarEditarGrupo(List<EntregaItem> grupo) {
    if (grupo.length == 1) {
      _mostrarEditarEntrega(grupo.first);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar entrega'),
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
                      _mostrarEditarEntrega(item);
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

  void _confirmarEliminarGrupo(List<EntregaItem> grupo) {
    if (grupo.length == 1) {
      _confirmarEliminar(grupo.first);
      return;
    }
    final texto = grupo.map((e) => e.displayProducto).join(', ');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entregas'),
        content: Text(
          'Se eliminarán ${grupo.length} entregas ($texto). Se restaurará el stock de todos. ¿Continuar?',
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
                await EntregarApi.eliminar(item.idEntrega);
                if (!mounted) return;
              }
              _cargarEntregas();
            },
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }
}

class _FormularioEntrega extends StatefulWidget {
  const _FormularioEntrega({
    required this.inventario,
    required this.solicitantes,
    required this.onExito,
    required this.onCancelar,
    required this.dialogContext,
    this.entregaExistente,
  });

  final List<InventarioItem> inventario;
  final List<String> solicitantes;
  final VoidCallback onExito;
  final VoidCallback onCancelar;
  final BuildContext dialogContext;
  final EntregaItem? entregaExistente;

  @override
  State<_FormularioEntrega> createState() => _FormularioEntregaState();
}

class _FilaProducto {
  _FilaProducto({this.idInventario}) : cantidadController = TextEditingController();
  int? idInventario;
  final TextEditingController cantidadController;
}

class _FormularioEntregaState extends State<_FormularioEntrega> {
  String? _sucursalSeleccionada;
  final List<_FilaProducto> _filasProducto = [];
  String? _errorStock;
  int? _errorFilaIndex;

  @override
  void initState() {
    super.initState();
    if (widget.entregaExistente != null) {
      final e = widget.entregaExistente!;
      _sucursalSeleccionada = e.nombreSucursal;
      _filasProducto.add(_FilaProducto(idInventario: e.fkIdInventario)
        ..cantidadController.text = e.cantidad.toString());
    } else {
      if (widget.solicitantes.isNotEmpty) _sucursalSeleccionada = widget.solicitantes.first;
      if (widget.inventario.isNotEmpty) {
        _filasProducto.add(_FilaProducto(idInventario: widget.inventario.first.idInventario));
      } else {
        _filasProducto.add(_FilaProducto());
      }
    }
  }

  @override
  void dispose() {
    for (final f in _filasProducto) f.cantidadController.dispose();
    super.dispose();
  }

  void _agregarOtraFila() {
    setState(() {
      final id = widget.inventario.isNotEmpty ? widget.inventario.first.idInventario : null;
      _filasProducto.add(_FilaProducto(idInventario: id));
      _errorStock = null;
      _errorFilaIndex = null;
    });
  }

  void _quitarFila(int index) {
    if (_filasProducto.length <= 1) return;
    setState(() {
      _filasProducto[index].cantidadController.dispose();
      _filasProducto.removeAt(index);
      _errorStock = null;
      _errorFilaIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.entregaExistente != null;

    return Container(
      width: 500,
      padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              esEdicion ? 'Editar Entrega' : 'Registrar Entrega',
              style: TextStyle(
                fontSize: 22,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _sucursalSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Sucursal / Solicitante',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Seleccionar solicitante'),
              items: widget.solicitantes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _sucursalSeleccionada = value),
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
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: fila.idInventario,
                        decoration: InputDecoration(
                          labelText: 'Producto',
                          border: const OutlineInputBorder(),
                          errorText: tieneError && _errorStock != null ? '' : null,
                        ),
                        hint: const Text('Seleccionar'),
                        items: widget.inventario
                            .map((inv) => DropdownMenuItem<int>(
                                  value: inv.idInventario,
                                  child: Text('${inv.displayNombre} (stock: ${inv.cantidad})'),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          fila.idInventario = value;
                          _errorStock = null;
                          _errorFilaIndex = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: fila.cantidadController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {
                          _errorStock = null;
                          _errorFilaIndex = null;
                        }),
                        decoration: InputDecoration(
                          labelText: 'Cant.',
                          border: const OutlineInputBorder(),
                          errorText: tieneError ? _errorStock : null,
                          errorStyle: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    if (_filasProducto.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _quitarFila(index),
                        tooltip: 'Quitar fila',
                      )
                    else
                      const SizedBox(width: 48),
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

            if (_errorStock != null && _errorFilaIndex == null) ...[
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
                        _errorStock!,
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
    );
  }

  Future<void> _guardar(BuildContext context) async {
    setState(() {
      _errorStock = null;
      _errorFilaIndex = null;
    });

    final sucursal = _sucursalSeleccionada?.trim();
    if (sucursal == null || sucursal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione sucursal / solicitante')),
      );
      return;
    }

    if (widget.entregaExistente != null) {
      final fila = _filasProducto.single;
      if (fila.idInventario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un producto del inventario')),
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
      final res = await EntregarApi.actualizar(
        widget.entregaExistente!.idEntrega,
        nombreSucursal: sucursal,
        idInventario: fila.idInventario,
        cantidad: cantidad,
      );
      if (!mounted) return;
      if (res.ok) {
        widget.onExito();
      } else {
        if (res.errorStock != null) {
          setState(() {
            _errorStock = '${res.errorStock!.message}. '
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
      if (fila.idInventario == null) {
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

    for (var i = 0; i < _filasProducto.length; i++) {
      final fila = _filasProducto[i];
      final cantidad = int.tryParse(fila.cantidadController.text.trim()) ?? 0;
      final res = await EntregarApi.crear(
        nombreSucursal: sucursal,
        idInventario: fila.idInventario!,
        cantidad: cantidad,
      );
      if (!mounted) return;
      if (!res.ok) {
        if (res.errorStock != null) {
          final inv = widget.inventario
              .where((x) => x.idInventario == fila.idInventario)
              .firstOrNull;
          final nombreProd = inv?.displayNombre ?? 'Producto';
          setState(() {
            _errorFilaIndex = i;
            _errorStock = '${nombreProd}: ${res.errorStock!.message}. '
                'Stock disponible: ${res.errorStock!.stockDisponible ?? "?"}. '
                'Solicitado: ${res.errorStock!.cantidadSolicitada ?? "?"}';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Error al registrar entrega')),
          );
        }
        return;
      }
    }
    widget.onExito();
  }
}
