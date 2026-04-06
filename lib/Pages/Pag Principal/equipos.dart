import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dim_equipos_lh_inventario_api.dart';

const _kEstados = ['Asignado', 'Baja', 'En Reparación', 'Disponible'];
const _kTiposEquipo = ['Notebook', 'Desktop', 'Servidor', 'Mini PC'];
const _kMarcas = [
  'Dell', 'HP', 'Lenovo', 'Asus', 'Acer', 'Samsung', 'Apple',
  'Epson', 'Brother', 'Canon', 'Generico'
];
const _kUbicaciones = [
  'Oficina Central', 'Planta Chocalan', 'Cullipeumo', 'Santa Ines',
  'Santa Victoria', 'Itahue', 'Hospital', 'Maiten', 'San Manuel'
];

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  List<DimEquipoLhInventario> _equipos = [];
  bool _cargando = true;
  final _scrollH = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _scrollH.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final data = await DimEquiposLhInventarioApi.listar();
    if (!mounted) return;
    setState(() {
      _equipos = data;
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
                          'Equipos',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Equipos / PC registrados.',
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
                                'Equipos',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Equipos / PC registrados',
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
    if (_equipos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.computer_outlined, color: Colors.white38, size: 64),
            const SizedBox(height: 12),
            Text(
              'Sin equipos registrados',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _scrollH,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollH,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
                    DataColumn(label: Text('Responsable')),
                    DataColumn(label: Text('Ubicación')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Modelo')),
                  ],
                  rows: _equipos.map((e) => _buildRow(e)).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(DimEquipoLhInventario e) {
    const cellStyle = TextStyle(color: Colors.white, fontSize: 13);
    return DataRow(
      onSelectChanged: (_) => _mostrarDetalle(e),
      cells: [
        DataCell(Text(e.codigoEquipo,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13))),
        DataCell(_estadoChip(e.estado)),
        DataCell(Text(e.responsable, style: cellStyle)),
        DataCell(Text(e.ubicacion, style: cellStyle)),
        DataCell(Text(e.tipo, style: cellStyle)),
        DataCell(Text(e.marca, style: cellStyle)),
        DataCell(Text(e.modelo, style: cellStyle)),
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

  void _mostrarDetalle(DimEquipoLhInventario e) {
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
                  const Icon(Icons.computer_outlined,
                      color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.codigoEquipo,
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
                      _detalleItem(
                          'Ubicación equipo', e.ubicacion, Icons.location_on_outlined),
                      _detalleItem('Tipo', e.tipo, Icons.devices_outlined),
                      _detalleItem('Marca', e.marca, Icons.business_center_outlined),
                      _detalleItem('Modelo', e.modelo, Icons.memory_outlined),
                      if (e.usuarioNombre.isNotEmpty)
                        _detalleItem(
                            'Registrado por', e.usuarioNombre, Icons.badge_outlined),
                      if (e.procesador.isNotEmpty)
                        _detalleItem('Procesador', e.procesador,
                            Icons.developer_board_outlined),
                      if (e.ram.isNotEmpty)
                        _detalleItem('RAM', e.ram, Icons.storage_outlined),
                      if (e.discoDuro.isNotEmpty)
                        _detalleItem('Disco duro', e.discoDuro, Icons.save_outlined),
                      if (e.sistemaOperativo.isNotEmpty)
                        _detalleItem('Sistema operativo', e.sistemaOperativo,
                            Icons.computer_outlined),
                      if (e.office.isNotEmpty)
                        _detalleItem('Office', e.office, Icons.article_outlined),
                      if (e.antivirus.isNotEmpty)
                        _detalleItem('Antivirus', e.antivirus,
                            Icons.security_outlined),
                      if (e.numeroSerie.isNotEmpty)
                        _detalleItem('N° de serie', e.numeroSerie,
                            Icons.tag_outlined),
                      if (e.fechaRevision.isNotEmpty)
                        _detalleItem('Fecha revisión', e.fechaRevision,
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
                      _mostrarFormulario(equipo: e);
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

  void _confirmarEliminar(DimEquipoLhInventario e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar equipo'),
        content: Text(
            '¿Eliminar "${e.codigoEquipo}" — ${e.responsable}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await DimEquiposLhInventarioApi.eliminar(e.idEquipos);
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

  void _mostrarFormulario({DimEquipoLhInventario? equipo}) {
    final esEdicion = equipo != null;

    final cCodigo = TextEditingController(text: equipo?.codigoEquipo ?? '');
    final cModelo = TextEditingController(text: equipo?.modelo ?? '');
    final cProcesador = TextEditingController(text: equipo?.procesador ?? '');
    final cRam = TextEditingController(text: equipo?.ram ?? '');
    final cDisco = TextEditingController(text: equipo?.discoDuro ?? '');
    final cSO = TextEditingController(text: equipo?.sistemaOperativo ?? '');
    final cOffice = TextEditingController(text: equipo?.office ?? '');
    final cAntivirus = TextEditingController(text: equipo?.antivirus ?? '');
    final cNumSerie = TextEditingController(text: equipo?.numeroSerie ?? '');
    final cFecha = TextEditingController(text: equipo?.fechaRevision ?? '');
    final cResponsable = TextEditingController(text: equipo?.responsable ?? '');

    String? selectedEstado = equipo?.estado;
    String? selectedTipo = equipo?.tipo;
    String? selectedMarca = equipo?.marca;
    String? selectedUbicacion = equipo?.ubicacion;

    int currentStep = 0;
    String? errorMsg;

    const stepTitles = ['Identificación', 'Asignación', 'Hardware', 'Software'];
    const stepSubtitles = [
      'Código, estado y tipo',
      'Nombre del responsable y ubicación del equipo',
      'Marca, modelo y specs',
      'SO, office, antivirus y detalles',
    ];

    String? validateStep(int step) {
      switch (step) {
        case 0:
          if (cCodigo.text.trim().isEmpty) return 'El código es obligatorio';
          if (selectedEstado == null) return 'Selecciona un estado';
          if (selectedTipo == null) return 'Selecciona un tipo';
          return null;
        case 1:
          if (cResponsable.text.trim().isEmpty) {
            return 'Ingrese el nombre del responsable';
          }
          if (selectedUbicacion == null) return 'Selecciona una ubicación';
          return null;
        case 2:
          if (selectedMarca == null) return 'Selecciona una marca';
          if (cModelo.text.trim().isEmpty) return 'El modelo es obligatorio';
          return null;
        default:
          return null;
      }
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (formCtx, setD) {
          Widget stepContent(bool narrowForm) {
            switch (currentStep) {
              case 0:
                return Column(children: [
                  _campo('Código *', cCodigo, enabled: !esEdicion),
                  const SizedBox(height: 14),
                  _dropdown('Estado *', selectedEstado, _kEstados,
                      (v) => setD(() => selectedEstado = v)),
                  const SizedBox(height: 14),
                  _dropdown('Tipo *', selectedTipo, _kTiposEquipo,
                      (v) => setD(() => selectedTipo = v)),
                ]);
              case 1:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _campo('Responsable *', cResponsable),
                    const SizedBox(height: 14),
                    _dropdown('Ubicación del equipo *', selectedUbicacion,
                        _kUbicaciones, (v) => setD(() => selectedUbicacion = v)),
                  ],
                );
              case 2:
                return Column(children: [
                  _dropdown('Marca *', selectedMarca, _kMarcas,
                      (v) => setD(() => selectedMarca = v)),
                  const SizedBox(height: 14),
                  _campo('Modelo *', cModelo),
                  const SizedBox(height: 14),
                  if (narrowForm) ...[
                    _campo('Procesador', cProcesador),
                    const SizedBox(height: 14),
                    _campo('RAM', cRam),
                  ] else
                    Row(children: [
                      Expanded(child: _campo('Procesador', cProcesador)),
                      const SizedBox(width: 12),
                      Expanded(child: _campo('RAM', cRam)),
                    ]),
                  const SizedBox(height: 14),
                  _campo('Disco Duro', cDisco),
                ]);
              case 3:
              default:
                return Column(children: [
                  if (narrowForm) ...[
                    _campo('Sistema Operativo', cSO),
                    const SizedBox(height: 14),
                    _campo('Office', cOffice),
                  ] else
                    Row(children: [
                      Expanded(child: _campo('Sistema Operativo', cSO)),
                      const SizedBox(width: 12),
                      Expanded(child: _campo('Office', cOffice)),
                    ]),
                  const SizedBox(height: 14),
                  _campo('Antivirus', cAntivirus),
                  const SizedBox(height: 14),
                  if (narrowForm) ...[
                    _campo('N° de serie', cNumSerie),
                    const SizedBox(height: 14),
                    _campo('Fecha revisión', cFecha, hint: 'YYYY-MM-DD'),
                  ] else
                    Row(children: [
                      Expanded(child: _campo('N° de serie', cNumSerie)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _campo('Fecha revisión', cFecha,
                              hint: 'YYYY-MM-DD')),
                    ]),
                ]);
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
                            const Icon(Icons.computer_outlined,
                                color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    esEdicion
                                        ? 'Editar equipo'
                                        : 'Agregar equipo',
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
                        child: currentStep < 3
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: Text('Siguiente  ${currentStep + 1}/4'),
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
                                  final campos = <String, dynamic>{
                                    'codigo_equipo': cCodigo.text.trim(),
                                    'estado': selectedEstado!,
                                    'antivirus': cAntivirus.text.trim(),
                                    'ubicacion': selectedUbicacion!,
                                    'tipo': selectedTipo!,
                                    'marca': selectedMarca!,
                                    'modelo': cModelo.text.trim(),
                                    'procesador': cProcesador.text.trim(),
                                    'ram': cRam.text.trim(),
                                    'disco_duro': cDisco.text.trim(),
                                    'sistema_operativo': cSO.text.trim(),
                                    'office': cOffice.text.trim(),
                                    'numero_serie': cNumSerie.text.trim(),
                                    'fecha_revision': cFecha.text.trim(),
                                    'responsable': cResponsable.text.trim(),
                                  };

                                  late ({bool ok, String? message}) res;
                                  if (esEdicion) {
                                    res = await DimEquiposLhInventarioApi.actualizar(
                                        equipo.idEquipos, campos);
                                  } else {
                                    final nuevo = DimEquipoLhInventario(
                                      idEquipos: 0,
                                      codigoEquipo: cCodigo.text.trim(),
                                      estado: selectedEstado!,
                                      antivirus: cAntivirus.text.trim(),
                                      ubicacion: selectedUbicacion!,
                                      tipo: selectedTipo!,
                                      marca: selectedMarca!,
                                      modelo: cModelo.text.trim(),
                                      procesador: cProcesador.text.trim(),
                                      ram: cRam.text.trim(),
                                      discoDuro: cDisco.text.trim(),
                                      sistemaOperativo: cSO.text.trim(),
                                      office: cOffice.text.trim(),
                                      numeroSerie: cNumSerie.text.trim(),
                                      fechaRevision: cFecha.text.trim(),
                                      fkIdUsuario: null,
                                      responsable: cResponsable.text.trim(),
                                      usuarioNombre: '',
                                      usuarioCorreo: '',
                                    );
                                    final r =
                                        await DimEquiposLhInventarioApi.crear(nuevo);
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
