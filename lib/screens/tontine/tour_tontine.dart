import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class tourTontine extends StatefulWidget {
  final Session listsession;
  const tourTontine({super.key, required this.listsession});

  @override
  State<tourTontine> createState() => _tourTontineState();
}

class _tourTontineState extends State<tourTontine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Planing des tours"),
        ),
      ),
      body: Padding(padding: EdgeInsets.all(8.0),child: Column(
        children: [
          SizedBox(height: 10,),
          Card(

            child: Row(
              children: [
                Column(
                  children: [
                    Text("Tour de ")
                  ],
                )
              ],
            ),
          )
        ],
      ),)
    );
  }
}
