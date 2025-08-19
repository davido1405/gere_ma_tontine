import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';

import 'auth/connexion_screen.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 400.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Welcome to GereMaTontine",
                style: TextStyle(
                  color: couleur.secondaryText,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold
                ),),
                Padding(
                  padding: EdgeInsets.all(55.0.w),
                  child: ElevatedButton.icon(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>connexion_screen()));
                  }, label: Text("Commencer",style: TextStyle(
                      fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),),icon: Icon(Icons.rocket_launch,color: Colors.white,),style: ElevatedButton.styleFrom(
                    backgroundColor: couleur.primaryPurple
                  ),),
                )
              ],
            ),
          ),
        )
      )
    );

  }
}
