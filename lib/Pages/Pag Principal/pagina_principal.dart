import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override 
  State<PaginaPrincipal> createState() => _PaginaPrincipal();


  }

  class _PaginaPrincipal extends State<PaginaPrincipal>{
    

    // VARIABLES //


    // PEQUEÑA SIMULACION DE NOMBRE DE USUARIO (PARA DESPUES TRAERLO CON AL BD )
    String _userName = "Sebastian";

    // FILTRO DE DIAS, MESES, AÑOS. PARA BUSCAR O FILTRAR ENTREGAS Y SALIDAS //

    String _SelectedFilter = "Hoy";

    final List<String> _filters = [
      "Hoy",
      "Esta Semana",
      "Este mes",
      "Este Año",
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      body: Container(

        /// FONDO DEGRADADO VERDE //
        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32), // Verde medio
              Color(0xFF43A047), // Verde más claro 
            ],
          ),
        ),

        child: SafeArea(  
            // SafeArea sirve para evitar que el contenido sea ocultado..
          child: Column(
            children: [


              // HEADER SUPERIOR //

              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFF1B5E20),

                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Row(
                    children: [

                      

                     // Titulo

                     Text(
                        
                        "Sistema Inventario",
                        style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          color: Colors.white,
                          fontSize: 26
                        ),
                     ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 7),  
                          child: Text(
                          "Bienvendio, $_userName",
                          style: TextStyle(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.white,
                            fontSize: 14
                         ),
                        ),
                      ),
                     const Spacer(),
                      
                      // DROPWDWON FILTRO PARA BUSCAR //
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // DropdownButtonHideUnderLine. ///
                        // Elimina la linea inferior que tiene por defecto. ///
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _SelectedFilter,
                            dropdownColor: Colors.green[700],
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            items: _filters.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),

                            /// Cuando cambia el valor (Hoy, Esta semana, Mes, Año.) ///
                            onChanged: (String? newValue){
                              setState(() {
                                _SelectedFilter = newValue!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 30),             
                    ],
                  ),
                ),
              ),


              // CUERPO PRINCIPAL DE LA APLICACION //
              
              Expanded(
                flex: 9,

                /// ROW divde la pantalla horizontalmente:
                /// Sidebar | Conenido ///
                
                child: Row(
                  children: [


                    /// SIDE BAR IZQUIERDO ///
                    
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white..withOpacity(0.08),

                        /// COLUMN organiza los iconos verticalmente ///
                        
                      ),
                    )
                  ],
                ),


              )
            
            
            ],
          ),

        ),

        ),
      );
  }
}