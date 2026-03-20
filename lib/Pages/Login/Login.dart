import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lh_tonner/Pages/Pag%20Principal/pagina_principal.dart';
import 'package:lh_tonner/services/api_client.dart';
import 'package:lh_tonner/services/dim_usuario_lh_toner_api.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginPageState();
}

class _loginPageState extends State<Login> {
  /// Ocultar/mostrar texto del campo (valor que se envía como `contrasenia` a la API).
  bool _obscureContrasenia = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();

  /// Mensajes de error (null = sin error). Mensaje encima del campo cuando aplica; el layout puede crecer.
  String? _emailError;
  String? _contraseniaError;

  /// True mientras se está validando con la API (muestra carga en el botón).
  bool _isLoading = false;

  /// Borde del campo: rojo si hay error; si no, como antes (sin borde).
  OutlineInputBorder _bordeCampo({required bool hayError}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: hayError ? BorderSide(color: Colors.red.shade700, width: 2) : BorderSide.none,
    );
  }

  /// Mensaje compacto: fondo transparente, borde ajustado al texto.
  Widget _cajaMensajeError(BuildContext context, String mensaje) {
    final maxW = MediaQuery.sizeOf(context).width - 72;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.red.shade400.withOpacity(0.9), width: 1),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 2,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade200, size: 15),
            Text(
              mensaje,
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contraseniaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text;
    final contrasenia = _contraseniaController.text;

    setState(() {
      _emailError = null;
      _contraseniaError = null;

      if (email.trim().isEmpty) {
        _emailError = 'Ingrese su correo o usuario';
      }
      if (contrasenia.isEmpty) {
        _contraseniaError = 'Ingrese su contraseña';
      }
    });
    if (_emailError != null || _contraseniaError != null) return;

    setState(() => _isLoading = true);
    final result = await DimUsuarioLhTonerApi.validar(email, contrasenia);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.ok) {
      if (result.token != null && result.token!.isNotEmpty) {
        ApiClient.setAuthToken(result.token);
      }
      final ident = email.trim();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaPrincipal(
            email: result.correo ?? (ident.contains('@') ? ident : null),
            nombreUsuario: result.nombre ?? 'Usuario',
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _emailError = null;
        _contraseniaError = null;
        final code = result.errorCode?.toUpperCase().trim();
        if (code == 'USER_NOT_FOUND') {
          // Ya ingresó datos: indicar qué dato es inválido (correo vs usuario).
          final ident = email.trim();
          _emailError =
              ident.contains('@') ? 'Correo incorrecto' : 'Usuario incorrecto';
        } else if (code == 'WRONG_PASSWORD') {
          _contraseniaError = 'Contraseña incorrecta';
        } else if (code == 'INVALID_EMAIL') {
          final m = result.message?.trim();
          _emailError =
              (m != null && m.isNotEmpty) ? m : 'Correo incorrecto';
        } else if (code == 'INVALID_IDENT') {
          final m = result.message?.trim();
          _emailError =
              (m != null && m.isNotEmpty) ? m : 'Usuario incorrecto';
        } else {
          final m = result.message?.trim() ?? '';
          if (m.isNotEmpty) {
            final low = m.toLowerCase();
            final textoSnack = (result.errorCode == null &&
                    (low.contains('credencial') ||
                        low.contains('inválid') ||
                        low.contains('invalid')))
                ? 'Revise el correo o usuario y la contraseña.'
                : m;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(textoSnack)),
              );
            });
          }
        }
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
                        if (_emailError != null) ...[
                          _cajaMensajeError(context, _emailError!),
                          const SizedBox(height: 8),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          onChanged: (_) => setState(() => _emailError = null),
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu correo o usuario',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.email,
                              color: _emailError != null ? Colors.red[700]! : Colors.green,
                            ),
                            border: _bordeCampo(hayError: _emailError != null),
                            enabledBorder: _bordeCampo(hayError: _emailError != null),
                            focusedBorder: _bordeCampo(hayError: _emailError != null),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Campo contraseña (API / BD: clave JSON `contrasenia`)
                        if (_contraseniaError != null) ...[
                          _cajaMensajeError(context, _contraseniaError!),
                          const SizedBox(height: 8),
                        ],
                        TextField(
                          controller: _contraseniaController,
                          obscureText: _obscureContrasenia,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _iniciarSesion(),
                          onChanged: (_) => setState(() => _contraseniaError = null),
                          decoration: InputDecoration(
                            hintText: 'Ingrese su contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: _contraseniaError != null ? Colors.red[700]! : Colors.green,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureContrasenia
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: _contraseniaError != null ? Colors.red[700] : null,
                              ),
                              onPressed: () {
                                setState(() => _obscureContrasenia = !_obscureContrasenia);
                              },
                            ),
                            border: _bordeCampo(hayError: _contraseniaError != null),
                            enabledBorder: _bordeCampo(hayError: _contraseniaError != null),
                            focusedBorder: _bordeCampo(hayError: _contraseniaError != null),
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