import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';
import 'package:gerematontine/screens/auth/mot_passe_oublie.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:gerematontine/screens/dashboard/participer.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class connexion_screen extends StatefulWidget {
  const connexion_screen({super.key});

  @override
  State<connexion_screen> createState() => _connexion_screenState();
}

class _connexion_screenState extends State<connexion_screen> {

  String? nom;
  String? prenom;
  String? numero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPrefs();
  }
  bool _cacher=true;
  bool cocher=false;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [IconButton(onPressed: () {
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
                height: 30.h,
              ),
              Center(child: Text("Bon retour parmis nous, $nom $prenom!",style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold
              ),)),
              SizedBox(height: 15.h,),
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
                  SizedBox(
                    height: 20.h,
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
                            ), child: Text("PIN oublié",style: TextStyle(
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
        ),
      )
      )
    );
  }
}
