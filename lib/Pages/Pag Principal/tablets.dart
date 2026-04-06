import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dim_tablets_lh_inventario_api.dart';

const _kEstadosTab = ['Asignado', 'Baja', 'En Reparación', 'Disponible'];

class TabletsPage extends StatefulWidget {
  const TabletsPage({super.key});

  @override
  State<TabletsPage> createState() => _TabletsPageState();
}

class _TabletsPageState extends State<TabletsPage> {
  List<DimTabletLhInventario> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final data = await DimTabletsLhInventarioApi.listar();
    if (!mounted) return;
    setState(() {
      _items = data;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tablets',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tablets registrados.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () => _mostrarFormulario(),
                            icon: const Icon(Icons.add_outlined,
                                color: Colors.white),
                            label: const Text('Agregar',
                                style: TextStyle(color: Colors.white)),
                          ),
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
                                'Tablets',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tablets registrados.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () => _mostrarFormulario(),
                          icon: const Icon(Icons.add_outlined,
                              color: Colors.white),
                          label: const Text('Agregar',
                              style: TextStyle(color: Colors.white)),
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
                child: _buildBody(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white70));
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tablet_android_outlined,
                color: Colors.white38, size: 64),
            const SizedBox(height: 12),
            Text(
              'Sin tablets registradas',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF1B5E20)),
                headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.4),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.white.withOpacity(0.10);
                  }
                  return Colors.transparent;
                }),
                columnSpacing: 16,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('Código')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Marca')),
                  DataColumn(label: Text('Modelo')),
                  DataColumn(label: Text('Capacidad')),
                  DataColumn(label: Text('Responsable')),
                ],
                rows: _items.map((e) => _buildRow(e)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(DimTabletLhInventario e) {
    const cellStyle = TextStyle(color: Colors.white, fontSize: 13);
    return DataRow(
      onSelectChanged: (_) => _mostrarDetalle(e),
      cells: [
        DataCell(Text(e.codigoTablet,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13))),
        DataCell(_estadoChip(e.estado)),
        DataCell(Text(e.marca, style: cellStyle)),
        DataCell(Text(e.modelo, style: cellStyle)),
        DataCell(Text(e.capacidad, style: cellStyle)),
        DataCell(Text(e.responsable, style: cellStyle)),
      ],
    );
  }

  Widget _estadoChip(String estado) {
    Color bg;
    Color fg;
    IconData icon;
    switch (estado.toLowerCase()) {
      case 'asignado':
        bg = const Color(0xFF2E7D32);
        fg = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case 'baja':
        bg = const Color(0xFFB71C1C);
        fg = Colors.white;
        icon = Icons.cancel_outlined;
        break;
      case 'en reparación':
        bg = const Color(0xFFE65100);
        fg = Colors.white;
        icon = Icons.build_outlined;
        break;
      case 'disponible':
        bg = const Color(0xFF0D47A1);
        fg = Colors.white;
        icon = Icons.inventory_2_outlined;
        break;
      default:
        bg = Colors.white24;
        fg = Colors.white;
        icon = Icons.circle_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 5),
          Text(
            estado,
            style: TextStyle(
                color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(DimTabletLhInventario e) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tablet_android_outlined,
                      color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.codigoTablet,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _estadoChip(e.estado),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _detalleItem('Responsable', e.responsable,
                          Icons.person_outline),
                      _detalleItem('Marca', e.marca, Icons.business_center_outlined),
                      _detalleItem('Modelo', e.modelo, Icons.memory_outlined),
                      if (e.capacidad.isNotEmpty)
                        _detalleItem('Capacidad', e.capacidad, Icons.sd_storage_outlined),
                      if (e.fechaEntrega.isNotEmpty)
                        _detalleItem('Fecha entrega', e.fechaEntrega,
                            Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _mostrarFormulario(item: e);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmarEliminar(e);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detalleItem(String label, String valor, IconData icon) {
    return SizedBox(
      width: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
                Text(valor.isEmpty ? '—' : valor,
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(DimTabletLhInventario e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tablet'),
        content: Text(
            '¿Eliminar "${e.codigoTablet}" — ${e.responsable}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await DimTabletsLhInventarioApi.eliminar(e.idTablet);
              if (!mounted) return;
              if (res.ok) {
                _cargar();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
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

  void _mostrarFormulario({DimTabletLhInventario? item}) {
    final esEdicion = item != null;
    final edit = item;

    final cCodigo = TextEditingController(text: item?.codigoTablet ?? '');
    final cMarca = TextEditingController(text: item?.marca ?? '');
    final cModelo = TextEditingController(text: item?.modelo ?? '');
    final cCap = TextEditingController(text: item?.capacidad ?? '');
    final cFecha = TextEditingController(text: item?.fechaEntrega ?? '');
    final cResponsable =
        TextEditingController(text: item?.responsable ?? '');

    String? selectedEstado = item?.estado;

    int currentStep = 0;
    String? errorMsg;

    const stepTitles = ['Identificación', 'Asignación', 'Hardware'];
    const stepSubtitles = [
      'Código y estado',
      'Nombre del responsable',
      'Marca, modelo, capacidad y entrega',
    ];

    String? validateStep(int step) {
      switch (step) {
        case 0:
          if (cCodigo.text.trim().isEmpty) return 'El código es obligatorio';
          if (selectedEstado == null) return 'Selecciona un estado';
          return null;
        case 1:
          if (cResponsable.text.trim().isEmpty) {
            return 'Ingrese el nombre del responsable';
          }
          return null;
        default:
          return null;
      }
    }

    const lastStepIndex = 2;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setD) {
          Widget stepContent(bool narrowForm) {
            switch (currentStep) {
              case 0:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _campo('Código tablet *', cCodigo, enabled: !esEdicion),
                    const SizedBox(height: 14),
                    _dropdown('Estado *', selectedEstado, _kEstadosTab,
                        (v) => setD(() => selectedEstado = v)),
                  ],
                );
              case 1:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _campo('Responsable *', cResponsable),
                  ],
                );
              case 2:
              default:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (narrowForm) ...[
                      _campo('Marca', cMarca),
                      const SizedBox(height: 14),
                      _campo('Modelo', cModelo),
                    ] else
                      Row(children: [
                        Expanded(child: _campo('Marca', cMarca)),
                        const SizedBox(width: 12),
                        Expanded(child: _campo('Modelo', cModelo)),
                      ]),
                    const SizedBox(height: 14),
                    _campo('Capacidad', cCap),
                    const SizedBox(height: 14),
                    _campo('Fecha entrega', cFecha,
                        hint: 'YYYY-MM-DD o texto'),
                  ],
                );
            }
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: LayoutBuilder(
              builder: (context, _) {
                final screenW = MediaQuery.sizeOf(context).width;
                final dialogW = (screenW - 24).clamp(280.0, 520.0);
                final pad = screenW < 600 ? 16.0 : 28.0;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: dialogW),
                  child: Container(
                    width: dialogW,
                    padding:
                        EdgeInsets.symmetric(horizontal: pad, vertical: pad),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tablet_android_outlined,
                                color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    esEdicion
                                        ? 'Editar tablet'
                                        : 'Agregar tablet',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    stepSubtitles[currentStep],
                                    style: TextStyle(
                                        fontSize: screenW < 600 ? 11 : 12,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(dialogCtx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStepIndicator(currentStep, stepTitles),
                        const SizedBox(height: 18),
                        if (errorMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_outlined,
                                    color: Colors.red[700], size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(errorMsg!,
                                      style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        LayoutBuilder(
                          builder: (_, bc) =>
                              stepContent(bc.maxWidth < 440),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                      if (currentStep > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Anterior'),
                            onPressed: () => setD(() {
                              errorMsg = null;
                              currentStep--;
                            }),
                          ),
                        ),
                      if (currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: currentStep < lastStepIndex
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: Text(
                                    'Siguiente  ${currentStep + 1}/${lastStepIndex + 1}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  final err = validateStep(currentStep);
                                  if (err != null) {
                                    setD(() => errorMsg = err);
                                    return;
                                  }
                                  setD(() {
                                    errorMsg = null;
                                    currentStep++;
                                  });
                                },
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 16),
                                label: Text(
                                    esEdicion ? 'Guardar cambios' : 'Agregar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  if (cCodigo.text.trim().isEmpty) {
                                    setD(() => errorMsg =
                                        'El código es obligatorio');
                                    return;
                                  }
                                  if (selectedEstado == null) {
                                    setD(() =>
                                        errorMsg = 'Selecciona un estado');
                                    return;
                                  }
                                  if (cResponsable.text.trim().isEmpty) {
                                    setD(() => errorMsg =
                                        'Ingrese el nombre del responsable');
                                    return;
                                  }
                                  final campos = <String, dynamic>{
                                    'codigo_tablet': cCodigo.text.trim(),
                                    'estado': selectedEstado!,
                                    'marca': cMarca.text.trim(),
                                    'modelo': cModelo.text.trim(),
                                    'capacidad': cCap.text.trim(),
                                    'fecha_entrega': cFecha.text.trim(),
                                    'responsable': cResponsable.text.trim(),
                                  };

                                  late ({bool ok, String? message}) res;
                                  if (esEdicion && edit != null) {
                                    res = await DimTabletsLhInventarioApi.actualizar(
                                        edit.idTablet, campos);
                                  } else {
                                    final nuevo = DimTabletLhInventario(
                                      idTablet: 0,
                                      codigoTablet: cCodigo.text.trim(),
                                      estado: selectedEstado!,
                                      marca: cMarca.text.trim(),
                                      modelo: cModelo.text.trim(),
                                      capacidad: cCap.text.trim(),
                                      fechaEntrega: cFecha.text.trim(),
                                      responsable: cResponsable.text.trim(),
                                    );
                                    final r =
                                        await DimTabletsLhInventarioApi.crear(nuevo);
                                    res = (ok: r.ok, message: r.message);
                                  }

                                  if (!mounted) return;
                                  if (res.ok) {
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                    }
                                    _cargar();
                                  } else {
                                    setD(() => errorMsg =
                                        res.message ?? 'Error al guardar');
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(int current, List<String> titles) {
    const doneColor = Color(0xFF2E7D32);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final fontSize = narrow ? 10.0 : 11.0;
        final gap = narrow ? 6.0 : 10.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < titles.length; i++) ...[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepCircle(i, current),
                    const SizedBox(height: 6),
                    Text(
                      titles[i],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.25,
                        fontWeight: i == current
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: i <= current ? doneColor : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < titles.length - 1)
                SizedBox(
                  width: gap,
                  height: 28,
                  child: Center(
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: i < current ? doneColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _stepCircle(int index, int current) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || active ? const Color(0xFF2E7D32) : Colors.grey[300],
        border: active
            ? Border.all(color: const Color(0xFF1B5E20), width: 2)
            : null,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {bool enabled = true, String? hint}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    final opts = (value != null && !items.contains(value))
        ? [value, ...items]
        : items;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      items: opts
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
