import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class creer_tontine extends StatefulWidget {
  const creer_tontine({super.key, required Session listsession});

  @override
  State<creer_tontine> createState() => _creer_tontineState();
}

class _creer_tontineState extends State<creer_tontine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Creer tontine"),
    );
  }
}
