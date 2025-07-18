import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class details_tontine extends StatefulWidget {
  const details_tontine({super.key, required Session listsession});

  @override
  State<details_tontine> createState() => _details_tontineState();
}

class _details_tontineState extends State<details_tontine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        child: Text("Details tontine"),
      ),
    );
  }
}
