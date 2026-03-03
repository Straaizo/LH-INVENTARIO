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
                       // _mostrarFormulario();
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
                 // _mostrarFormulario();
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
}

