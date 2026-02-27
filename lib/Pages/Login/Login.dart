
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/Pages/Pag%20Principal/pagina_principal.dart';



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginPageState();
  
  }

  class _loginPageState extends State<Login>{


  /// Variable para controlar la visibilidad de la contraseña.
  bool _obscurePassword = true;  
  @override
  Widget build(BuildContext context) {

    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LH TONNER',
      home: Scaffold(
        body: Stack(
       /// Stack permite superponer widgets uno encima de otro
        /// En este caso:
        /// 1️⃣ Imagen de fondo ///
        /// 2️⃣ Overlay oscuro ///
        /// 3️⃣ Contenido principal ///
        children: [

          // IMAGEN DE FONDO //

          Positioned.fill(
            // Positioned.fill hace que el widget ocupe todo el espacio disponible.
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover
              // BoxFit.cover hace que la imagen seleccionada cubra toda la pantalla.
            ),
          ),

         // OVERLAY OSCURO //

          Positioned.fill(
            child: Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.35),
              // Este overlay oscurece la imagen un poco para que el texto y los campos sean visibles.
            ),
          ),

          // CONTENIDO PRINCIPAL (CAMPOS DE ENTRADA) //
          SafeArea(
            // SafeArea ajusta el contenido automaticamente.
            child: Column(

              children: [
                // HEADER //

                Expanded(
                  // Expanded hace que este widget ocupe una parte -> //
                  // proporiconal segun el flex. //
                  flex: 3,
                  // flex 3 significa que ocupara  partes del expanded //

                  child: Center(
                    // Centra al siguiente child (hijo).
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Centra todo verticalmente el siguiente contenido.

                        children: [

                          // LOGO LH //

                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Image.asset('assets/images/logo_lh.png'),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // TITULO //
                          
                          Text(
                            'Iniciar Sesion',
                            style: TextStyle(
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              color: Colors.white,
                              fontSize: 22
                            ),
                          ), 

                          const SizedBox(height: 2),

                          // SUB TITULO //

                           Text(
                            'Sistema Inventario',
                            style: TextStyle(
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              color: Colors.white70,
                              fontSize: 18
                            ),
                          ),


                        
                        ],
                      ),
                    ),
                 ),
                
                /// FORMULARIO EMAIL Y/O USUARIO / CONTRASEÑA /// 
              
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    // Este padding agrega un espacio interno horizontal. //
                    child: Column (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // CAMPO USUARIO - EMAIL //

                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingrese su correo',
                            filled: true, 
                            // FILLED sirve para activar el color de fondo en componentes (TextFields, Inputs ETC..)
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.green,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CAMPO CONTRASEÑA //
                        TextField(
                          obscureText: _obscurePassword,
                          // Esto hace que la contraseña se oculte si el bool es 
                          // (true el cual)
                          // esta mas arriba detallado //
                          decoration: InputDecoration(
                            hintText: 'Ingrese su Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.green,
                            ),
                            suffixIcon: IconButton(
                              // Boton para mostrar / ocultar la contraseña.
                              icon: Icon(
                                _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              ),
                              onPressed: () {
                                
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            )
                          ),
                        ),
                        const SizedBox(height: 35),

                        // BOTON LOGIN / ENTRAR //
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          // double.infinity hace que ocupe todo el ancho.
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(30),
                              ),
                            ),
                            onPressed: (
                            ){
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaginaPrincipal(),
                                ),
                              (Route<dynamic> route) => false,
                              );
                            },
                            icon: const Icon(Icons.login,
                            color: Colors.white),
                            label: Text(
                              'Iniciar Sesion',
                              style: TextStyle(
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                                fontSize: 16,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                      ],
                     ),
                    ),
                  ),
                ),
              ),
              //  FOOTER //
               Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                      child:  Text(
                        'Desarrollado por el departamento de TI de la Hornilla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          color: Colors.white70,
                          fontSize: 17,
                        ),
                        
                      ),
                      
                      
                    ),
                  ),
                  
                ),
                const SizedBox(height: 35)
                
              
              ],
              
            ),
          ),

        ],
        
        
        ),
      ),
    );
   }
  }