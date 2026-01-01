import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';
import 'package:gerematontine/screens/auth/mot_passe_oublie.dart';
import 'package:gerematontine/screens/dashboard/participer.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/Acceuil.dart';

class connexion_screen extends StatefulWidget {
  const connexion_screen({super.key});

  @override
  State<connexion_screen> createState() => _connexion_screenState();
}

class _connexion_screenState extends State<connexion_screen> {

  String? nom;
  String? prenom;
  String? numero;
  String? idantifiant;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPrefs();
  }
  bool _cacher=true;
  bool cocher=false;
  bool erreurConn=false;
  String message="";
  TextEditingController pinController=TextEditingController();
  TextEditingController mot_pass=TextEditingController();
  late Session listsession;

  Future<void>initSharedPrefs() async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      nom=prefs.getString('nom');
      prenom=prefs.getString('prenom');
      numero=prefs.getString('mobile');
    });
  }

  Future<void> verifierLien(String token) async {
    try {
      final url = Uri.parse("$adress?ressource=tontines&action=verifierInvitation");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultat = jsonDecode(response.body);
        if (resultat['success']) {
          final data = resultat['data'];
          // On peut stocker certaines infos si besoin
          listsession.setCodeTontine(data['code_tontine']);
        } else {
          _showErreur(resultat['message'] ?? "Lien invalide ou expiré");
        }
      } else {
        _showErreur("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      _showErreur("Une erreur est survenue: $e");
    }
  }

  void _showErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  //Fonction async de connexion
  Future<void>connexion(String numero,String password)async{
    final url=Uri.parse("$adress?ressource=participants&action=connexion_participant");
    final response=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      "numero_participant":numero,
      "password":password
    })).timeout(Duration(seconds: 15));
    if(response.statusCode==200){
      var data=jsonDecode(response.body) as Map<String,dynamic>;
      bool success=data['success'];
      if(success==true && data['message']=="Connexion réussie"){
        var parti=data['data'];
        listsession=Session.fromJson(parti);
        print(listsession);
        //Sécuriser le JWT après reception
        await listsession.secureJwt();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>acceuil(listsession: listsession)),(route)=>false);
      }else if(success==true && data['message']=="Connexion réussie (pas encore de tontine)"){
        var parti=data['data'];
        listsession=Session.fromJson(parti);
        //Sécuriser le JWT après reception
        await listsession.secureJwt();
        //Verifier s'il y'a un lien d'invitation
        final prefs=await SharedPreferences.getInstance();
        if(prefs.getString('token_invitation')!=null){
          String? token_invitation=prefs.getString('token_invitation');
          await verifierLien(token_invitation!);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>acceuil(listsession: listsession)), (route)=>false);
        }else{
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>participer(listsession: listsession)),(route)=>false);
        }
        }else{
        showDialog(context: context, builder: (BuildContext contex){
          return AlertDialog(
            title: Center(child: Text('Erreur'),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Lottie.asset("assets/animations/Sign for error _ Flat style.json",width: 150.w,height: 150.h),),
                Center(child: Text("Pin incorrect",overflow: TextOverflow.ellipsis,maxLines: 2,)),
              ],
            ),
            actions: [
              Center(
                child:TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                },style: TextButton.styleFrom(
                    backgroundColor: Couleur.secondaryGreen
                ),icon: Icon(Icons.verified,color: Colors.white,), label: Text("Compris",style: TextStyle(color: Colors.white),)),
              )
            ],
          );
        });
      }
    }else{
      setState(() {
        erreurConn=true;
        message="Service momentanément indisponible, Veuillez réssayer dans quelques instants.";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [IconButton(onPressed: () async {
            await FirebaseMessaging.instance.deleteToken();
            Navigator.push(context, MaterialPageRoute(builder: (_)=>inscription_screen()));
        }, icon: Icon(Icons.logout,size:30.r,color: Colors.black,)),],),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset("assets/Djarra Finances V1.png",width: 150.w,height: 150.h,)),
              SizedBox(
                height: 10.h,
              ),
              Center(child: Column(
                children: [
                  Text("C'est bon de vous revoir",style: TextStyle(
                    fontSize: 18.sp,
                  ),),
                  SizedBox(height: 10.h,),
                  Text("$nom $prenom !",style: TextStyle(
                    fontSize: 18.sp,
                  ))
                ],
              )),
              SizedBox(
                height: 30.h,
              ),
              Center(
                child: Text("Veuillez saisi votre code Djarra",style: TextStyle(
                  fontSize: 18.sp,
                ),),
              ),
              Padding(padding: EdgeInsets.only(top: 10,right: 30,left: 30),
                  child: Column(
                children: [
                  Pinput(
                    length: 6,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    controller: pinController,
                    onCompleted: (pin)async{
                      final SharedPreferences prefs=await SharedPreferences.getInstance();
                      connexion(numero!, pinController.text);
                    },
                  ),
                  SizedBox(height: 10.h,),
                  Center(child: Text(message,style: TextStyle(
                    color: erreurConn?Colors.red:Colors.transparent
                  ),),),
                  SizedBox(
                    height: 30.h,
                  ),
                  Center(
                    child: TextButton(onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>mot_passe_oublie()));
                    },style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent) //Décactiver l'animation autour du bouton
                    ), child: Text("Code Djarra oublié ?",style: TextStyle(
                      fontSize: 14.sp,
                    )
                    )
                    ),
                  )
                ],
              )
              ),
            ],
          ),
        ),
      )
      )
    );
  }
}
