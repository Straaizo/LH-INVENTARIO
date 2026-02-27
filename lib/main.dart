import 'package:flutter/material.dart';
import 'package:lh_tonner/Pages/Login/Login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:   false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green
      ),
      home: const Login(),
    );
  }
}