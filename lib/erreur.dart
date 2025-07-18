import 'package:flutter/material.dart';

class erreur extends StatefulWidget {
  const erreur({super.key});

  @override
  State<erreur> createState() => _erreurState();
}

class _erreurState extends State<erreur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("Erreur"),
      ),
    );
  }
}
