import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class participer_tontine extends StatefulWidget {
  const participer_tontine({super.key, required Session listsession});

  @override
  State<participer_tontine> createState() => _participer_tontineState();
}

class _participer_tontineState extends State<participer_tontine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Participer à tontine"),
    );
  }
}
