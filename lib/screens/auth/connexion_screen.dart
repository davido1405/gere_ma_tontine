import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';
import 'package:gerematontine/screens/auth/mot_passe_oublie.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:gerematontine/screens/dashboard/participer.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class connexion_screen extends StatefulWidget {
  const connexion_screen({super.key});

  @override
  State<connexion_screen> createState() => _connexion_screenState();
}

class _connexion_screenState extends State<connexion_screen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  bool _cacher=true;
  bool cocher=false;
  TextEditingController email=TextEditingController();
  TextEditingController mot_pass=TextEditingController();
  late Session listsession;

  //Fonction async de connexion

  Future<void>connexion(String email,String password)async{
    final url=Uri.parse("$adress?ressource=participants&action=connexion_participant");
    final response=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      "email_participant":email,
      "password":password
    })).timeout(Duration(seconds: 15));
    if(response.statusCode==200){
      var data=jsonDecode(response.body) as Map<String,dynamic>;
      bool success=data['success'];
      if(success==true && data['message']=="Connexion réussie"){
        var parti=data['data'];
        setState(() {
          Session listsession=Session.fromJson(parti);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>dashboard(listsession: listsession)),(route)=>false);
        });
      }else if(success==true && data['message']=="Connexion réussie (pas encore de tontine)"){
        var parti=data['data'];
        setState(() {
          Session listsession=Session.fromJson(parti);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>participer(listsession: listsession)),(route)=>false);
        });
      }else{
        showDialog(context: context, builder: (BuildContext contex){
          return AlertDialog(
            title: Center(child: Text('Erreur'),),
            content: Text(data['message']),
            actions: [
              Center(
                child:TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text("Compris")),
              )
            ],
          );
        });
      }
    }
  }
  //Future<void>resterConnecte()async{
    //final preference=await SharedPreferences.getInstance();
    //await preference.setBool('estConnecte', cocher);
    //await preference.setString('utilisateur', listsession.toString());
  //}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: null,
      ),
      body: SafeArea(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome back",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: couleur.secondaryText
            ),),
            Padding(padding: EdgeInsets.only(top: 25,right: 30,left: 30),
                child: Column(
              children: [
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                      label: Text("Email",style: TextStyle(
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
                    prefixIcon: Icon(Icons.email)
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),

                TextField(
                  controller: mot_pass,
                  obscureText: _cacher,
                  decoration: InputDecoration(
                    label: Text("Mot de passe",style: TextStyle(
                      fontSize: 16.sp,
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
                      child: Icon(_cacher ? Icons.visibility_off:Icons.visibility),
                    )
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: (){
                      String mail=email.text;
                      String motpass=mot_pass.text;
                      //resterConnecte();
                      connexion(mail, motpass);
                      },style: ElevatedButton.styleFrom(
                        backgroundColor: couleur.primaryPurple
                      ), child: Text("Login",style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp
                      ),),)
                    )
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0.w,right: 40.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 20,
                          child: TextButton(onPressed: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>mot_passe_oublie()));
                          },style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.transparent) //Décactiver l'animation autour du bouton
                          ), child: Text("Mot de passe oublié",style: TextStyle(
                            fontSize: 14.sp,
                              decoration: TextDecoration.underline
                          )
                          )
                          ),
                      ),
                      Expanded(
                          flex: 10,
                          child: TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>inscription_screen()));
                          },style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(Colors.transparent) //Décactiver l'animation autour du bouton
                          ), child: Text("S'incrire",style: TextStyle(
                              fontSize: 14.sp,
                              decoration: TextDecoration.underline
                          )
                          )
                          ),
                      )
                    ],
                  ),
                )
              ],
            )
            ),
          ],
        ),
      )
      )
    );
  }
}
