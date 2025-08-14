import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class modifier_profil extends StatefulWidget {
  const modifier_profil({super.key, required Session listsession});

  @override
  State<modifier_profil> createState() => _modifier_profilState();
}

class _modifier_profilState extends State<modifier_profil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Modifier mon profile"),),
      ),
    );
  }
}
