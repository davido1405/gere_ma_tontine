import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/auth/confirmation_numero.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';
import '../dashboard/participer.dart';

class inscription_screen extends StatefulWidget {
  const inscription_screen({super.key});

  @override
  State<inscription_screen> createState() => _inscription_screenState();
}

class _inscription_screenState extends State<inscription_screen> {
  
  TextEditingController nom=TextEditingController();
  TextEditingController prenoms=TextEditingController();
  TextEditingController numero=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool _cacher=true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Inscription",style: TextStyle(fontSize:22.sp,fontWeight: FontWeight.bold),),),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.only(top: 20.h),
        child: Padding(
          padding: EdgeInsets.only(left: 20.w,right: 20.w),
          child: Column(
            children: [
              Image.asset("assets/Djarra Finances V1.png",width: 150.w,height: 150.h,),
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
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: couleur.lightGray)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: couleur.lightGray)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: couleur.secondaryText)
                    )
                ),
              ),
              SizedBox(
                height: 35.h,
              ),
              TextField(
                controller: numero,
                decoration: InputDecoration(
                    label:Text("Numéro de téléphone",style: TextStyle(
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
                  Expanded(child: ElevatedButton(onPressed: () async {
                    SharedPreferences prefs=await SharedPreferences.getInstance();
                    prefs.setString("nom", nom.text);
                    prefs.setString("prenom", prenoms.text);
                    prefs.setString("mobile", "+225${numero.text}");
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ConfirmationNumero()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: couleur.primaryPurple
                  ), child: Text("Suivant",style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp
                  ),),))
                ],
              )
            ],
          ),
        ),),
      ),
    );
  }
}
