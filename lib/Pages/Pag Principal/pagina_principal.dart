import 'dart:ui';
import 'package:lh_inventario/Pages/Login/Login.dart';
import 'package:lh_inventario/services/api_client.dart';
import 'package:lh_inventario/services/dim_usuario_lh_inventario_api.dart';

import 'celulares.dart';
import 'entrada.dart';
import 'equipos.dart';
import 'impresoras.dart';
import 'inventario.dart';
import 'productos.dart';
import 'salida.dart';
import 'tablets.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key, this.email, this.nombreUsuario = 'Usuario'});

  /// Email del usuario logueado. Si se pasa, el menú principal busca el nombre en la API/tabla.
  final String? email;

  /// Nombre por defecto si no se pasa email o mientras se carga desde la API.
  final String nombreUsuario;

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipal();
}

class _PaginaPrincipal extends State<PaginaPrincipal> {
  String _SelectedMenu = "Salida";
  late String _nombreEnHeader;

  @override
  void initState() {
    super.initState();
    _nombreEnHeader = widget.nombreUsuario;
    // Con JWT: refrescar nombre desde /me (incluye `usuario.nombre`). Con correo: perfil por email.
    if (ApiClient.hasAuthToken ||
        (widget.email != null && widget.email!.trim().isNotEmpty)) {
      _cargarNombreDesdeApi();
    }
  }

  Future<void> _cargarNombreDesdeApi() async {
    final nombre = await DimUsuarioLhInventarioApi.obtenerNombreUsuario(widget.email ?? '');
    if (!mounted) return;
    if (nombre.isNotEmpty && nombre != 'Usuario') {
      setState(() => _nombreEnHeader = nombre);
    }
  }





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
                              _nombreEnHeader,
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
              Color(0xFF2E7D32),
              Color(0xFF43A047),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── HEADER SUPERIOR (altura fija) ────────────────────────
              SizedBox(
                height: isMobile ? 56 : 64,
                child: Container(
                  color: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (isMobile)
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          "Sistema de Inventario",
                          style: TextStyle(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 24,
                          ),
                        ),
                      ),
                      if (!isMobile)
                        Text(
                          "Bienvenido, $_nombreEnHeader",
                          style: TextStyle(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── CUERPO PRINCIPAL (ocupa el resto de la pantalla) ─────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Sidebar desktop
                    if (!isMobile)
                      SizedBox(
                        width: 220,
                        child: Container(
                          color: const Color(0xFF2E7D32),
                          child: SingleChildScrollView(
                            child: _sidebarItems(),
                          ),
                        ),
                      ),

                    // Contenido principal
                    Expanded(
                      child: _buildContent(),
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
      case "Salida":
        return const SalidaPage();
      case "Entrada":
        return const EntradaPage();
      case "Inventario":
        return const InventarioPage();
      case "Productos":
        return const ProductosPage();
      case "Equipos":
        return const EquiposPage();
      case "Celulares":
        return const CelularesPage();
      case "Tablets":
        return const TabletsPage();
      case "Impresoras":
        return const ImpresorasPage();
      default:
        return const SalidaPage();
    }
  }
 
 
 
 
 
 
 
 // SIDEBAR ITEMS //
Widget _sidebarItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        const SizedBox(height: 20),
        _buildItem("Salida", Icons.outbox_outlined),
        const SizedBox(height: 8),
        _buildItem("Entrada", Icons.move_to_inbox_outlined),
        const SizedBox(height: 8),
        _buildItem("Inventario", Icons.inventory_outlined),
        const SizedBox(height: 8),
        _buildItem("Productos", Icons.local_shipping_outlined),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.white.withOpacity(0.2), height: 1),
        ),
        const SizedBox(height: 12),
        _buildItem("Equipos", Icons.computer_outlined),
        const SizedBox(height: 8),
        _buildItem("Celulares", Icons.phone_android_outlined),
        const SizedBox(height: 8),
        _buildItem("Tablets", Icons.tablet_android_outlined),
        const SizedBox(height: 8),
        _buildItem("Impresoras", Icons.print_outlined),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.white.withOpacity(0.2), height: 1),
        ),
        const SizedBox(height: 12),
        _buildItem("Salir", Icons.logout_outlined),
        const SizedBox(height: 16),

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
          child: Container(
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
                        ApiClient.setAuthToken(null);
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