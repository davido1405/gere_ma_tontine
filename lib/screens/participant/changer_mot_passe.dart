import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';

class changer_mot_passe extends StatefulWidget {
  final Session listsession;
  const changer_mot_passe({super.key, required this.listsession});

  @override
  State<changer_mot_passe> createState() => _changer_mot_passeState();
}

class _changer_mot_passeState extends State<changer_mot_passe> {

  Future<void>modifierMotpass()async{

  }

  bool _cacher=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Changer mon code secret",style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold
        ),),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0.w),
        child: Column(
          children: [
            SizedBox(
              height: 30.h,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hint: Text("Saisissez l'ancien code secret",style: TextStyle(
                fontSize: 14.sp,
                ),),
                filled: true,
                fillColor: couleur.lightGray,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: couleur.primaryPurple),
                    borderRadius: BorderRadius.circular(12.r)
                ),

              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            TextField(
              obscureText: _cacher,
              decoration: InputDecoration(
                hint: Text("Saisissez le nouveau code secret",style: TextStyle(
                    fontSize: 14.sp,
                ),),
                filled: true,
                  fillColor: couleur.lightGray,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: couleur.primaryPurple)
                  ),
                  suffixIcon: GestureDetector(
                    onTap: (){
                      setState(() {
                        _cacher=!_cacher;
                      });

                      Future.delayed(Duration(seconds: 3),(){
                        setState(() {
                          _cacher=true;
                        });
                      });
                    },
                    child: Icon(_cacher? Icons.visibility:Icons.visibility_off,),
                  )
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  _cacher=!_cacher;
                });
              },
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hint: Text("Répétez le nouveau code secret",style: TextStyle(
                    fontSize: 14.sp,
                  ),),
                  filled: true,
                  fillColor: couleur.lightGray,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: couleur.primaryPurple),
                      borderRadius: BorderRadius.circular(12.r)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
              child: TextButton.icon(onPressed: (){
                print("Vous avez changé votre code secret");
              }, label: Text("Changer mon code secret",style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white
              ),
              ),
                  icon: Icon(Icons.check_circle,color: Colors.white),style: TextButton.styleFrom(
                  backgroundColor: couleur.primaryPurple
                ),),
            )
          ],
        ),
      ),
    );
  }
}
