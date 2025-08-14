import 'package:flutter/material.dart';import 'package:gerematontine/screens/splashScreen.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/constants/colors.dart';

import 'constants/colors.dart'; // si tu utilises couleur.primaryPurple

void main() {
  runApp(
     const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const splashScreen(),
            '/screens/auth/connexion_screen': (context) => const connexion_screen(),
          },
        );
  }
}

