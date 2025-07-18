import 'package:flutter/material.dart';
import 'package:gerematontine/screens/splashScreen.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context)=>splashScreen(),
        '/screens/auth/connexion_screen':(context)=>connexion_screen(),
      },
    )
  );
}



