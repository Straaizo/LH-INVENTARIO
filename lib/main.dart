import 'package:flutter/material.dart';
import 'package:lh_inventario/Pages/Login/Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LH Inventario',
      debugShowCheckedModeBanner:   false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green
      ),
      home: const Login(),
    );
  }
}