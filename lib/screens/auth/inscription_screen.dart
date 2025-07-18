import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class inscription_screen extends StatefulWidget {
  const inscription_screen({super.key});

  @override
  State<inscription_screen> createState() => _inscription_screenState();
}

class _inscription_screenState extends State<inscription_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription"),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.only(top: 20),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nom",
                    filled: true,
                    fillColor: couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: couleur.lightGray)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: couleur.secondaryText)
                    )
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Prenoms",
                      filled: true,
                      fillColor: couleur.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.lightGray)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.secondaryText)
                      )
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextField(
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
                      )
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                      filled: true,
                      fillColor: couleur.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.lightGray)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.secondaryText)
                      )
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextField(
                  decoration: InputDecoration(
                    label: Text("Numéro Mobile Money"),
                      filled: true,
                      fillColor: couleur.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.lightGray)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.secondaryText)
                      )
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: (){}, child: Text("M'inscrir",style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                    ),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleur.primaryPurple
                    ),))
                  ],
                )
              ],
            ),
          ),
        ),),
      ),
    );
  }
}
