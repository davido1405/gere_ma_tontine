import 'dart:convert';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
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
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.setBool("inscriptionTermine", true);
        setState((){
          _listsession=Session.fromJson(finalUser);
        });
        await _listsession.secureJwt();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>participer(listsession: _listsession,)), (route)=>false);
      }else{
        SharedPreferences prefs=await SharedPreferences.getInstance();
        setState(() {
          prefs.remove('nom');
          prefs.remove('prenom');
          prefs.remove('mobile');
          prefs.remove('identifiant');
        });
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(
              child: Text(
                "Erreur",
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            content: SizedBox(
              height: 200.h,
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animations/Sign for error _ Flat style.json',
                    width: 100.w,
                    height: 100.h,
                  ),
                  Center(
                    child: Text(
                      user['message'],
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Couleur.secondaryGreen,
                  ),
                  icon: const Icon(Icons.verified, color: Colors.white),
                  label: Text(
                    "Compris",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          );
        });
      }
    }else{
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: Duration(seconds: 2),
        builder: (BuildContext context) {
          return ToastCard(
            title: Row(
              mainAxisAlignment:MainAxisAlignment.start,
              children: [
                Column(
                children: [
                  Icon(Icons.error_outline,color: Colors.white,size: 30.r,),
                ],
              ),Column(
                children: [
                  Text("Une erreur s'est produite",style: TextStyle(
                      color: Colors.white
                  ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                  Text("Contactez le service technique. Merci",style: TextStyle(
                      color: Colors.white
                  ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                ],
              )],),
            color: Colors.red.shade700,);
        },).show(context) as SnackBar;
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
            height: 5.h,
          ),
          Lottie.asset("assets/animations/Mobile Security.json",width: 350.w,height: 350.h),
          SizedBox(
            height: 15.h,
          ),
          Text(confirmation?"Veuillez confirmer votre code Djarra Finances":"Veuillez saisir votre code Djarra Finances"),
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
