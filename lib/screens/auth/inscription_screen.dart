import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        title: Center(child: Text("Inscription",style: TextStyle(fontSize:22.sp,fontWeight: FontWeight.bold),),),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.only(top: 20.h),
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w,right: 20.w),
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                ),
                TextField(
                  controller: nom,
                  decoration: InputDecoration(
                    label: Text("Nom",style: TextStyle(
                      fontSize: 16.sp
                    ),),
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
                  height: 35.h,
                ),
                TextField(
                  controller: prenoms,
                  decoration: InputDecoration(
                    label: Text("Prénoms",style: TextStyle(
                        fontSize: 16.sp
                    ),),
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
                  height: 35.h,
                ),
                TextField(
                  controller: mail,
                  decoration: InputDecoration(
                    label:Text("E-mail",style: TextStyle(
                        fontSize: 16.sp
                    ),),
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
                  height: 35.h,
                ),
                TextField(
                  controller: motpass,
                  obscureText: _cacher,
                  decoration: InputDecoration(

                    label: Text("Mot de passe",style: TextStyle(
                        fontSize: 16.sp
                    ),),
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
                  height: 35.h,
                ),
                TextField(
                  controller: numero,
                  decoration: InputDecoration(
                    label:Text("Numéro Wave",style: TextStyle(
                        fontSize: 16.sp
                    ),),
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
                  height: 25.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: (){
                      inscription();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleur.primaryPurple
                    ), child: Text("M'inscrire",style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp
                    ),),))
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
