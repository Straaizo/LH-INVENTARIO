import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();

}

class _ProductosPageState extends State<ProductosPage>{

  // LISTA SIMULADA //
  List<Map<String, String>> productos = [
    {"nombre": "CF238A", "categoria": "Tóner"},
    {"nombre": "CF279A", "categoria": "Tóner"},
    {"nombre": "TN1060", "categoria": "Tóner"},
    {"nombre": "105A", "categoria": "Tóner"},
    {"nombre": "TN860XL", "categoria": "Tóner"},
    {"nombre": "TN450", "categoria": "Tóner"},
    {"nombre": "DR1060", "categoria": "Tambor"},
    {"nombre": "DR2370", "categoria": "Tambor"},
  ];

  @override
Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

  
    Map<String, List<Map<String, String>>> agrupados = {};

    for (var producto in productos) {
      agrupados.putIfAbsent(producto["categoria"]!, () => []);
      agrupados[producto["categoria"]]!.add(producto);
    }

    return Column(
      children: [
        // HEADER //
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
          child: isMobile

          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                   Text(
                  "Producto",
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
                        backgroundColor: Colors.green[700],
                        
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

              // VERSION DE PC //
            : Row(
              children: [

                Text(
                  "Producto",
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
                    // 
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
            child: ListView(
              children: agrupados.entries.map((entry) {
                  String categoria = entry.key;

                  List<Map<String, String>> listaProductos = entry.value;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // TITULO CATEGORIA //
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

                      // PRODUCTOS //
                      ...listaProductos.map((productos) {
                        return ListTile(
                          leading: const Icon(
                            Icons.print_outlined,
                            color: Colors.greenAccent,
                          ),
                          title: Text(
                            productos["nombre"]!,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                color: Colors.white70),
                                onPressed: () {},
                              ),
                                 IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                color: Colors.white70),
                                onPressed: () {},
                              ),
                                 IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white70,
                                size: 16),
                                onPressed: () {},
                                 )
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
}