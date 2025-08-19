import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';

class mot_passe_oublie extends StatefulWidget {
  const mot_passe_oublie({super.key});

  @override
  State<mot_passe_oublie> createState() => _mot_passe_oublieState();
}

class _mot_passe_oublieState extends State<mot_passe_oublie> {
  TextEditingController email=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Mot de passe oublié",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w,right: 20.w),
          child: Container(
            child: Padding(padding: EdgeInsets.only(top: 35.h),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
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
                  )
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left:20.w,right: 20.w),
                  child: Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: (){
                        String mail=email.text;
                        var data=jsonEncode(
                          {
                            "email":mail
                          }
                        );
                        print(data);
                      }, child: Text("Reinitialiser mot de passe",style: TextStyle(

                        color: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleur.primaryPurple
                      ),))
                    ],
                  ),
                )
              ],
            ),)
          ),
        ))
    );
  }
}
