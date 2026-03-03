import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {

  List<Map<String, dynamic>> inventario = [
    {"producto": "DR1060", "stock": 13},
    {"producto": "DR2370", "stock": 16},
    {"producto": "105A", "stock": 2},
    {"producto": "CF238A", "stock": 31},
    {"producto": "CF279A", "stock": 1},
    {"producto": "TN450", "stock": 17},
    {"producto": "TN860XL", "stock": 5},
    {"producto": "TN1060", "stock": 19},
    {"producto": "TN2370", "stock": 33},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
          
          bool isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              // HEADER RESPONSIVO //
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
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
                        

                      
                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              //_mostrarformulario();
                            },
                            icon: Icon(Icons.add_outlined,
                            color: Colors.white),
                            label: Text("Añadir",
                            style: TextStyle(
                              color: Colors.white
                            ),)

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
                      onPressed: () {
                        _mostrarFormulario();
                      },
                      icon: Icon(Icons.add_outlined,
                      color: Colors.white,),
                      label: Text("Añadir",
                      style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
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
                    child: ListView.builder(
                      itemCount: inventario.length,
                      itemBuilder: (context, index){
                        final item = inventario[index];
                        int stock = item["stock"];

                        // SI EL STOCK ES BAJO MOSTRAMOS UNA ALERTA //
                        bool bajoStock = stock <= 5;

                        return ListTile(
                          leading: const Icon(Icons.print_outlined, color: Colors.white,),
                          title: Text(
                            item["producto"],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                bajoStock
                                ? Icons.warning_outlined
                                : Icons.check_outlined,
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
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
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

void _mostrarFormulario(){

  TextEditingController productoController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(25),
          child: Column (
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                  "Añadir Stock",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),

              const SizedBox(height: 20),

              TextField(
                controller: productoController,
                decoration: const InputDecoration(
                  labelText: "Producto",
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cantidad",
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

                        setState(() {
                          inventario.add({
                            "producto": productoController.text,
                            "stock": int.tryParse(stockController.text) ?? 0,
                          });
                        });

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
      }
    );
  }
}