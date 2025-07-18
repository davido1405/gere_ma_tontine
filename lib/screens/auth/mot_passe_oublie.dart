import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';

class mot_passe_oublie extends StatefulWidget {
  const mot_passe_oublie({super.key});

  @override
  State<mot_passe_oublie> createState() => _mot_passe_oublieState();
}

class _mot_passe_oublieState extends State<mot_passe_oublie> {
  TextEditingController email=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mot de passe oublié"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Container(
            child: Padding(padding: EdgeInsets.only(top: 35),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: couleur.lightGray)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: couleur.secondaryText)
                    ),
                  )
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:20,right: 20),
                  child: Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: (){
                        String mail=email.text;
                        var data=jsonEncode(
                          {
                            "email":mail
                          }
                        );
                        print(data);
                      }, child: Text("Reinitialiser mot de passe",style: TextStyle(
                        color: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleur.primaryPurple
                      ),))
                    ],
                  ),
                )
              ],
            ),)
          ),
        ))
    );
  }
}
