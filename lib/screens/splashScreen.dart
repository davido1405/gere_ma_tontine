import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/connexion_screen.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  String? nom;
  String? prenom;
  String? numero;
  int index=0;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _redirection();

    _timer=Timer.periodic(Duration(milliseconds: 800),(timer){
      if(!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        index++;
      });
    });
  }

  Future<void>_redirection() async{
    final prefs =await SharedPreferences.getInstance();
    final nom= prefs.getString('nom');
    final prenom = prefs.getString('prenom');
    final numero = prefs.getString('mobile');

    //Léger temps d'attente
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(
            builder: (context)=>numero != null ? const connexion_screen():const inscription_screen()),
            (route)=>false
    );
  }

  Color getRandomColor( String input, int index){
    final hash=input.hashCode+index;
    final couleurs=[Colors.deepOrange,Colors.amber,Colors.cyan,Colors.green,Colors.red,Colors.blue];
    return couleurs[hash % couleurs.length];
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Center(
            child: Container(
              padding: EdgeInsets.only(top: 400.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/Djarra Finances V1.png",width: 150.w,height: 150.h,),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(55.0.w),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(getRandomColor("david",index)),
                          backgroundColor: Colors.black12,
                          strokeWidth: 5,
                        ),
                        Center(child: Text("Chargement...",style: TextStyle(
                            fontSize: 20.sp
                        ),),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      )
    );

  }
}
