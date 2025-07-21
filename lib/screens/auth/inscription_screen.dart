import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:http/http.dart' as http;

import '../../constants/colors.dart';
import '../dashboard/participer.dart';

class inscription_screen extends StatefulWidget {
  const inscription_screen({super.key});

  @override
  State<inscription_screen> createState() => _inscription_screenState();
}

class _inscription_screenState extends State<inscription_screen> {
  
  TextEditingController nom=TextEditingController();
  TextEditingController prenoms=TextEditingController();
  TextEditingController mail=TextEditingController();
  TextEditingController motpass=TextEditingController();
  TextEditingController numero=TextEditingController();

  late Session _listsession;
  
  //Inscription
  Future<void>inscription() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=participants&action=inscrir_participant");
    final reponse=await http.post(url,headers: {'content-Type':"application/json"},body: jsonEncode(
        {
          "nom": nom.text,
          "prenom": prenoms.text,
          "email": mail.text,
          "password": motpass.text,
          "mobile": numero.text
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic> user=jsonDecode(reponse.body);
      bool success=user['success'];
      if(success){
        var finalUser=user['data'];
        setState(() {
          _listsession=Session.fromJson(finalUser);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>participer(listsession: _listsession,)), (route)=>false);
        });
      }else{
        print(user['success']);
      }
    }else{
      print("Une erreur server est survenu");
    }
  }

  bool _cacher=true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Inscription",style: TextStyle(fontWeight: FontWeight.bold),),),
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
                  controller: nom,
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
                  controller: prenoms,
                  decoration: InputDecoration(
                    labelText: "Prénoms",
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
                  controller: mail,
                  decoration: InputDecoration(
                    labelText: "E-mail",
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
                  controller: motpass,
                  obscureText: _cacher,
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
                      ),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          _cacher=!_cacher;
                        });
                      },
                      child: _cacher? Icon(Icons.visibility):Icon(Icons.visibility_off),
                    )
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextField(
                  controller: numero,
                  decoration: InputDecoration(
                    label: Text("Numéro Wave"),
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
                    Expanded(child: ElevatedButton(onPressed: (){
                      inscription();
                    }, child: Text("M'inscrire",style: TextStyle(
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
