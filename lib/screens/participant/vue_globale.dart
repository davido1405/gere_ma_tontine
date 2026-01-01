import 'package:flutter/material.dart';

import '../../models/session.dart';

class vue_global extends StatefulWidget {
  final Session listsession;
  const vue_global({super.key, required this.listsession});

  @override
  State<vue_global> createState() => _vue_globalState();
}

class _vue_globalState extends State<vue_global> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Résumé"),),);
  }
}
