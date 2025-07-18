import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class parametre extends StatefulWidget {
  const parametre({super.key, required Session listsession});

  @override
  State<parametre> createState() => _parametreState();
}

class _parametreState extends State<parametre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parametre"),
      ),
      body: Text("Parametre"),
    );
  }
}
