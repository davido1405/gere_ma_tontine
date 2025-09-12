import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/server.dart';
import '../dashboard/participer.dart';

class Definirpin extends StatefulWidget {
  const Definirpin({super.key});

  @override
  State<Definirpin> createState() => _DefinirpinState();
}

class _DefinirpinState extends State<Definirpin> {
  final secretCodeController=TextEditingController();
  String? premierCode;

  late Session _listsession;
  bool confirmation=false;

  //Inscription
  Future<void>inscription(String x,String y,String w,String z) async{
    final url=Uri.parse("${adress}?ressource=participants&action=inscrir_participant");
    final reponse=await http.post(url,headers: {'content-Type':"application/json"},body: jsonEncode(
        {
          "nom": x,
          "prenom": y,
          "password":w,
          "mobile": z
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
        print(user['success'] + user['message']);
      }
    }else{
      print("Une erreur server est survenu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Definir votre code secret")),
      ),
      body: Padding(padding: EdgeInsets.all(12),child: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          Icon(Icons.security_outlined,size: 100.r,color: Colors.blue,),
          SizedBox(
            height: 15.h,
          ),
          Text(confirmation?"Veuillez confirmer votre code secret":"Veuillez saisir votre code secret"),
          SizedBox(
            height: 15.h,
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: Pinput(
              length: 6,
              keyboardType: TextInputType.number,
              controller: secretCodeController,
              obscureText: true,
              onCompleted: (pin) async {
                if(premierCode==null){
                  setState(() {
                    premierCode=secretCodeController.text;
                    secretCodeController.clear();
                    confirmation=true;
                  });
                }else if(premierCode==secretCodeController.text){
                  SharedPreferences prefs=await SharedPreferences.getInstance();
                  inscription(prefs.getString("nom").toString(), prefs.getString("prenom").toString(),(secretCodeController.text).toString(), prefs.getString("mobile").toString());
                }
              },
            ),
          )
        ],
      ),),
    );
  }
}
