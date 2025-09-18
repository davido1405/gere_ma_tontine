import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:gerematontine/screens/tontine/creer_tontine.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/colors.dart';
import '../../constants/server.dart';

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
  String? scannedCode;

  Future<void>participer()async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participations&action=participer");
    final response=await http.post(
        url,
        headers:{
          "Authorization":"Bearer $jwt",
          "content-Type":"application/json",
        },
        body:jsonEncode({
          "code_participant":widget.listsession.code_participant,
          "code_tontine":code.text
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(response.body);
      bool success=data['success'];
      if(success){
        if(data['message']=="Vous participez désormais à cette tontine"){
          setState(() {
            widget.listsession.setCodeTontine(code.text);
          });
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession)), (route)=>false);
        }else if(data['message']=="Vous êtes déjà inscrit dans cette tontine"){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession)), (route)=>false);
        }
      }else{
        showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text("Erreur"),
              content: Text(data['message']),
              actions: [
                TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                },style: TextButton.styleFrom(
                    backgroundColor: Couleur.primaryBlue
                ), label: Text("Compris"),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
              ],
            );
          });
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
          Center(child: SizedBox(
            width: 300.w,
            height: 300.h,
            child: Center(child: Container(
              color: Colors.grey,
              child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(16.r),
              child: MobileScanner(
                onDetect: (capture){
                  final List<Barcode> barcodes=capture.barcodes;
                  for(final barcode in barcodes){
                    final String? qr=barcode.rawValue;
                    if(qr!=null && qr.startsWith("tontine_plus/")){
                      setState(() {
                        code.text=qr.split('/')[1].toString();
                      });
                      participer();
                      //break;
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            color: Colors.blue,
                            padding: EdgeInsets.all(8.w),
                            height: 80.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.report_outlined,color: Colors.red,size: 40.r,),
                                SizedBox(width: 20.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Echec"),
                                      Spacer(),
                                      Text("Veuillez scanner un QRCode Djarra Finances")
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 3,
                        )
                      );
                    }
                  }
                },
              ),),
              ),
            )),
          ),
          SizedBox(
            height: 30.h,
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
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: TextField(
                  controller: code,
                  obscureText: _cacher,
                  decoration: InputDecoration(
                    label: Text("Code tontine",style: TextStyle(
                        fontSize: 16.sp
                    ),),
                    filled: true,
                    fillColor: Couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Couleur.primaryBlue)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Couleur.primaryBlue),
                      borderRadius: BorderRadius.circular(12.r)
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
                height: 15.h,
              ),
              Center(
                child: TextButton.icon(onPressed: (){
                  participer();
                }, label: Text("Participer",style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white
                ),),icon: Icon(Icons.rocket_launch,color: Colors.white,),style: TextButton.styleFrom(
                  backgroundColor: Couleur.primaryBlue
                ),)),
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>creer_tontine(listsession: widget.listsession,)));
                },style: TextButton.styleFrom(
                    backgroundColor: Couleur.primaryBlue
                ), label: Text("Créer ma tontine",style: TextStyle(
                  fontSize: 14.sp,
                    color: Colors.white
                ),),icon: Icon(Icons.rocket_launch,color: Colors.white,)),
              )
            ],
          ),)
        ],
      ),
    );
  }
}
