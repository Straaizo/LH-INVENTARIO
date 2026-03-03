import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class InventarioPage extends StatelessWidget {
  const InventarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        "Inventario",
        style: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
      ),
    );
  }
}