import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/Pages/Pag%20Principal/pagina_principal.dart';
import 'package:lh_tonner/services/login_api.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginPageState();
}

class _loginPageState extends State<Login> {
  /// Variable para controlar la visibilidad de la contraseña.
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Mensajes de error (null = sin error). Se muestra subrayado rojo y texto debajo del campo.
  String? _emailError;
  String? _passwordError;

  /// True mientras se está validando con la API (muestra carga en el botón).
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;

      if (email.trim().isEmpty) {
        _emailError = 'Ingrese su correo';
      }
      if (password.isEmpty) {
        _passwordError = 'Ingrese su contraseña';
      }
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    final result = await LoginApi.validar(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaPrincipal(
            email: email.trim().isEmpty ? null : email.trim(),
            nombreUsuario: result.nombre ?? 'Usuario',
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _emailError = result.message;
        _passwordError = result.message;
      });
    }
  }

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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          onChanged: (_) => setState(() => _emailError = null),
                          decoration: InputDecoration(
                            hintText: 'Ingrese su correo',
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _emailError,
                            errorStyle: TextStyle(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: _emailError != null ? Colors.red[700]! : Colors.green,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CAMPO CONTRASEÑA //
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _iniciarSesion(),
                          onChanged: (_) => setState(() => _passwordError = null),
                          decoration: InputDecoration(
                            hintText: 'Ingrese su Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _passwordError,
                            errorStyle: TextStyle(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: _passwordError != null ? Colors.red[700]! : Colors.green,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // BOTON LOGIN / ENTRAR //
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading ? null : _iniciarSesion,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Cargando...' : 'Iniciar Sesion',
                              style: TextStyle(
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                                fontSize: 16,
                                color: Colors.white,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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