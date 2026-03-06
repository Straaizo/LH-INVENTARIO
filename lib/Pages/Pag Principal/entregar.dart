import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';


class EntregarPage extends StatefulWidget {
  const EntregarPage({super.key});

  State<EntregarPage> createState() => _EntregarPageState();

}
 


class _EntregarPageState extends State<EntregarPage>{

  List<Map<String, String>> entregas = [
    {"fecha": "23/2/2026", "solicitante": "Maitén", "productos": "TN2370 (4)"},
    {"fecha": "19/2/2026", "solicitante": "Santa Victoria", "productos": "DR2370 (2)"},
    {"fecha": "17/2/2026", "solicitante": "Oficina Central", "productos": "TN1060 (1)"},
  ];

    // LISTA DE SOLICITANTES
  List<String> solicitantes = [
    "Oficina Central",
    "Santa Victoria",
    "Cullipeumo",
    "Hospital",
    "Santa Inés",
    "Maitén",
    "San Manuel",
    "Itahue",
  ];

  // LISTA DE PRODUCTOS
  List<String> productos = [
    "TN2370",
    "TN1060",
    "TN860XL",
    "TN450",
    "CF238A",
    "CF279A",
    "DR1060",
    "DR2370",
  ];
 
  List<ProductoEntrega> productosEntrega = [ProductoEntrega()];
  
  @override
  Widget build(BuildContext context) {

    // LAYOUT BUILDER nos permite detectar el ancho disponible //
    // Para sabar si estamos en un dispositivo movil o PC //
    return LayoutBuilder(
      builder: (context, constraints) {
      
      
      bool isMobile = constraints.maxWidth < 600;
      
      return Column(
      children: [

        // Header responsivo  //
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),




            // VERSION MOVIL //
          child: isMobile

          ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TITULO //
              Text(
                "Entregar",
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
                        backgroundColor: Colors.green[700],
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.download_outlined,
                      color: Colors.white),
                      label: Text("Excel",
                      style: TextStyle(color: Colors.white)
                      ),
                    ),

                 
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        
                      ),
                      onPressed: () {
                       _mostrarFormularioEntregar();
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



          : Row(
            children: [

              Text(
                "Entregar",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),

              const Spacer(),

              // BOTON DE DESCARGAR PLANILLA //
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                ),
                onPressed: () {

                },
                icon: const Icon(Icons.download_outlined,
                color: Colors.white,),
                label: const Text('Excel',
                style: TextStyle(
                  color: Colors.white
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Boton Agregar //
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  _mostrarFormularioEntregar();
                },
                icon:  Icon(Icons.add_outlined,
                color: Colors.white,),
                label:  Text('Agregar',
                style: TextStyle(
                  color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),


        // LISTA DE DATOS //
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: entregas.length,
              itemBuilder: (context, index){
                final item = entregas[index];

                return ListTile(
                  title: Text(
                    item["fecha"]!,
                    style:  TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${item["solicitante"]} - ${item["productos"]}",
                    style:  TextStyle(color : Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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

  void _mostrarFormularioEntregar() {

    String? solicitanteSeleccionado;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
    
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Container(
                width: 450,
                
                padding: const EdgeInsets.all(25),

    

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Registrar Entrega",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= SOLICITANTE =================

                    DropdownButtonFormField<String>(
                      value: solicitanteSeleccionado,
                      hint: const Text("Seleccionar solicitante"),
                      items: solicitantes.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          solicitanteSeleccionado = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // ================= PRODUCTOS DINAMICOS =================

                    Column(
                      children: List.generate(productosEntrega.length, (index) {

                        return Column(
                          children: [

                            Row(
                              children: [

                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: productosEntrega[index].producto,
                                    hint: const Text("Producto"),
                                    items: productos.map((p) {
                                      return DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        productosEntrega[index].producto =
                                            value;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextField(
                                    controller:
                                        productosEntrega[index].cantidad,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Cantidad",
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 10),

                    // ================= BOTON AGREGAR PRODUCTO =================

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setStateDialog(() {
                            productosEntrega.add(ProductoEntrega());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar otro producto"),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [

                        Expanded(
                          child: OutlinedButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Text("Cancelar"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {

                              String fechaHoy =
                                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

                              String productosTexto = productosEntrega.map((p) {
                                return "${p.producto} (${p.cantidad.text})";
                              }).join(", ");

                              setState(() {
                                entregas.add({
                                  "fecha": fechaHoy,
                                  "solicitante": solicitanteSeleccionado ?? "",
                                  "productos": productosTexto
                                });
                              });

                              productosEntrega = [ProductoEntrega()];

                              Navigator.pop(context);
                            },
                            child: const Text("Guardar"),
                          ),
                        )
                      ],
                    )
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
class ProductoEntrega {
  String? producto;
  TextEditingController cantidad = TextEditingController();
  }
