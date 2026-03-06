import 'dart:ui';
import 'package:lh_tonner/Pages/Login/Login.dart';

import 'entregar.dart';
import 'inventario.dart';
import 'productos.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override 
  State<PaginaPrincipal> createState() => _PaginaPrincipal();


  }

  class _PaginaPrincipal extends State<PaginaPrincipal>{
    

    // VARIABLES //

    String _SelectedMenu = "";

    // PEQUEÑA SIMULACION DE NOMBRE DE USUARIO (PARA DESPUES TRAERLO CON AL BD )
    String _userName = "Sebastian";

    // FILTRO DE DIAS, MESES, AÑOS. PARA BUSCAR O FILTRAR ENTREGAS Y SALIDAS //



  @override
  Widget build(BuildContext context) {

    return  LayoutBuilder(
      builder: (context, constraints) {
      
      bool isMobile = constraints.maxWidth < 700;
      
      return Scaffold(

        drawer: isMobile
          ? Drawer(
            child: Container(
              color:const Color(0xFF2E7D32),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bienvenido,",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: GoogleFonts.montserrat().fontFamily
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      Divider(color: Colors.white.withOpacity(0.2)),
                  
                      const SizedBox(height: 20),

                      _sidebarItems(),
                      
                    ],
                  ),
                ),
              ),
            ),
          )
          : null,

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

                          if (isMobile)
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                         ),
                      ),

                     // Titulo
                    Expanded(
                      child: Text(
                        "Sistema Inventario",
                        style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 26,
                        ),
                     ),
                    ),
                    if (!isMobile)
                      Padding(
                        padding:  EdgeInsets.only(left: 5, top: 7, right: 25),  
                          child: Text(
                          "Bienvenido, $_userName",
                          style: TextStyle(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.white,
                            fontSize: 14
                         ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // CUERPO PRINCIPAL DE LA APLICACION //
              
              Expanded(
                flex: 9,

                /// ROW divde la pantalla horizontalmente:
                /// Sidebar | Conenido ///
                
                /// SIDE BAR PARA EL MOVIL ///
                child: Row(
                  children: [
                      if (!isMobile)
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.only(top: 25),
                          child: _sidebarItems(),
                        ),
                      ),

                    /// SIDE BAR IZQUIERDO ///
                    /// CUERPO AL LADO DEL SIDE BAR//
                    
                    Expanded(
                      flex: 4,
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildContent(),
                        ),     
                      ),
                    ],
                  ),
                ),
              ],
            ),          
          ),
        ),                
      );                  
    },                        
  );
}                   
 
 
 Widget _buildContent() {
    switch (_SelectedMenu) {
      case "Entregar":
        return const EntregarPage();
      case "Inventario":
        return const InventarioPage();
      case "Productos":
        return const ProductosPage();
      default:
        return const EntregarPage();
    }
  }
 
 
 
 
 
 
 
 // SIDEBAR ITEMS //
Widget _sidebarItems() {
    return Column(
      
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        _buildItem("Entregar", Icons.shopping_cart_outlined),
        const SizedBox(height: 25),
        _buildItem("Inventario", Icons.inventory_outlined),
        const SizedBox(height: 25),
        _buildItem("Productos", Icons.local_shipping_outlined),
        const SizedBox(height: 35),
        _buildItem("Salir", Icons.logout_outlined),

      ],
    );
  }

  //  ITEM INDIVIDUAL //
Widget _buildItem(String label, IconData icon) {
    return MouseRegion(
      


      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){
            if (label == "Salir") {
              _MostrarDialogoSalir();
            } else {
            setState(() {
              _SelectedMenu = label;
            });

            // PARA QUE CIERRE EL SIDE BAR CADA VEZ QUE SE SELECCIONE UNO //
            if (MediaQuery.of(context).size.width < 700) {
                Navigator.pop(context);
            }
            
            }
          },
          hoverColor: Colors.white.withOpacity(0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            color: _SelectedMenu == label
                ? const Color(0xFF1E6F2A)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



void _MostrarDialogoSalir() {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_outlined,
                size: 40,
                color: Colors.red[400],
              ),
              const SizedBox(height: 15),

              Text("¿Seguro que quieres salir?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.montserrat().fontFamily
                ),
              ),
              
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancelar"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                      ),
                      onPressed: () {

                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Salir"),
                    ),
                  ),
                ],
              )

              
            ],
          ),
        ),
      );
    },
  );
  }
}