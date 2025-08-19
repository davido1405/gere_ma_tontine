import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:gerematontine/screens/tontine/creer_tontine.dart';
import 'package:http/http.dart' as http;
import '../../constants/colors.dart';

class participer extends StatefulWidget {
  final Session listsession;
  const participer({super.key, required this.listsession});

  @override
  State<participer> createState() => _participerState();
}

class _participerState extends State<participer> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController code=TextEditingController();
  bool _cacher=true;

  Future<void>participer()async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=participations&action=participer");
    final response=await http.post(url,headers:{"content-Type":"application/json"},body:jsonEncode({
          "code_participant":widget.listsession.code_participant,
          "code_tontine":code.text
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(response.body);
      bool success=data['success'];
      if(success){
        setState(() {
          widget.listsession.setCodeTontine(code.text);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession)), (route)=>false);
        });
      }else{
        if(data['message']=="Vous êtes déjà inscrit dans cette tontine"){
          setState(() {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession)), (route)=>false);
          });
        }else{
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text("Erreur"),
              content: Text(data['message']),
              actions: [
                TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                }, label: Text("Compris"),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
              ],
            );
          });
          print(data['message']);
          print(widget.listsession.code_participant);
        }
        }
    }else{
      showDialog(context: context, builder: (BuildContext contex){
        return AlertDialog(
          title: Center(child: Text("Erreur",style: TextStyle(fontWeight: FontWeight.bold),),),
          content: Text("Une erreur s'est produite côté serveur. Veuillez réessayer plus tard"),
          actions: [
            Center(child: TextButton.icon(onPressed: (){
              Navigator.of(context).pop();
            }, label: Text("D'accord"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
          ],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Participer",style: TextStyle(
            fontSize: 20.sp,
              fontWeight: FontWeight.bold,letterSpacing: 1),),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30.h,),
          Center(
            child: Text("Scanner le QR Code de la tontine",style: TextStyle(
              fontSize: 14.sp
            ),),
          ),
          SizedBox(height: 50.h,),
          Center(child: Container(
            width: 300.w,
            height: 300.h,
            child: Center(child: Container(
              color: Colors.grey,
              child: Text("Un text"),
              ),
            )),
          ),
          SizedBox(
            height: 30,
          ),
          Center(child: Column(
            children: [
              Text("Ou vous avez un code de tontine ?",style: TextStyle(
                  fontSize: 14.sp
              ),),
              SizedBox(
                height: 15.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w,right: 15.w),
                child: TextField(
                  controller: code,
                  obscureText: _cacher,
                  decoration: InputDecoration(
                    label: Text("Code tontine",style: TextStyle(
                        fontSize: 16.sp
                    ),),
                    filled: true,
                    fillColor: couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: couleur.primaryPurple)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: couleur.primaryPurple),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    prefixIcon: Icon(Icons.lock),
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
                      child: _cacher? Icon(Icons.visibility):Icon(Icons.visibility_off),
                    )
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: TextButton.icon(onPressed: (){
                  participer();
                }, label: Text("Participer",style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white
                ),),icon: Icon(Icons.rocket_launch,color: Colors.white,),style: TextButton.styleFrom(
                  backgroundColor: couleur.primaryPurple
                ),)),
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>creer_tontine(listsession: widget.listsession,)));
                }, label: Text("Créer ma tontine",style: TextStyle(
                  fontSize: 14.sp,
                    color: Colors.white
                ),),icon: Icon(Icons.rocket_launch,color: Colors.white,),style: TextButton.styleFrom(
                    backgroundColor: couleur.primaryPurple
                ),),
              )
            ],
          ),)
        ],
      ),
    );
  }
}
