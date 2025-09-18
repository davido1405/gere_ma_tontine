import 'dart:async';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/screens/auth/DefinirPin.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ConfirmationNumero extends StatefulWidget {
  const ConfirmationNumero({super.key});

  @override
  State<ConfirmationNumero> createState() => _ConfirmationNumeroState();
}

class _ConfirmationNumeroState extends State<ConfirmationNumero> {

  final pinController=TextEditingController();
  int second=30;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = ''; // à remplir après l'envoi OTP

  String? numero;


  void startTimer(){
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (second > 0) {
        setState(() {
          second--;
        });
      } else {
        t.cancel(); // Stop le timer
      }
    });

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    sendOtp();
  }
  
  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendOtp() async {
    // Récupère le numéro depuis SharedPreferences
    SharedPreferences prefs=await SharedPreferences.getInstance();
    setState(() {
      numero = prefs.getString('mobile');
    });
    if (numero == null || numero!.isEmpty) {
      print("Erreur: Numéro de téléphone non trouvé");
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: Duration(seconds: 2),
        builder: (BuildContext context) {
          return ToastCard(
            title: Row(
              mainAxisAlignment:MainAxisAlignment.start,
              children: [Icon(Icons.error_outline,color: Colors.white,size: 30.r,),Text("Erreur: Numéro de téléphone non trouvé",style: TextStyle(
                  color: Colors.white
              ),)],),
            color: Colors.red.shade700,);
        },).show(context);
    }

    print("Envoi OTP vers: $numero");
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: Duration(seconds: 2),
      builder: (BuildContext context) {
        return ToastCard(
          title: Row(
            mainAxisAlignment:MainAxisAlignment.start,
            children: [Icon(Icons.info,color: Colors.white,size: 30.r,),Text("OTP envoyé au ${numero}",style: TextStyle(
                color: Colors.white
            ),overflow: TextOverflow.ellipsis,maxLines: 2,)],),
          color: Colors.green.shade700,);
      },).show(context);

    await _auth.verifyPhoneNumber(
      phoneNumber: numero, // ton numéro complet
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        //Definirpin();
        print("$numero");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Erreur OTP: ${e.message}");
        print("$numero");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        print("OTP envoyé ID: $_verificationId");
        print("$numero");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
        print("$numero");
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmer votre numéro"),
      ),
      body: Padding(padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          SizedBox(height: 10.h,),
          Image.asset("assets/confirmation.png",width: 150.w,height: 150.h,),
          SizedBox(
            height: 15.h,
          ),
          Text("Veuillez saisir le code OTP reçu par SMS"),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: Pinput(
              length: 6,
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              onCompleted: (pin) async {
                try {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId,
                    smsCode: pin,
                  );
                  await _auth.signInWithCredential(credential);
                  // OTP correct → passer à écran définir code secret
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Definirpin()), (route)=>false);
                } catch (e) {
                  print("OTP incorrect: $e");
                  final prefs=await SharedPreferences.getInstance();
                  setState(() {
                    prefs.remove('nom');
                    prefs.remove('prenom');
                    prefs.remove('mobile');
                    prefs.remove('identifiant');
                  });
                  DelightToastBar(
                    position: DelightSnackbarPosition.top,
                    autoDismiss: true,
                    snackbarDuration: Duration(seconds: 2),
                    builder: (BuildContext context) {
                      return ToastCard(
                        title: Row(
                          mainAxisAlignment:MainAxisAlignment.start,
                          children: [Icon(Icons.error_outline,color: Colors.white,size: 30.r,),Text("Veuillez vérifier le code OTP ou le numéro saisi",style: TextStyle(
                              color: Colors.white
                          ),maxLines: 2,overflow: TextOverflow.ellipsis,)],),
                        color: Colors.red.shade700,);
                    },).show(context);
                }
              },
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          second > 0
              ? Text("Renvoyer un autre code dans ${second}s")
              : GestureDetector(
            onTap: () {
              timer?.cancel();
              setState(() {
                second = 30; // réinitialiser le timer
              });
              sendOtp();
              startTimer();
            },
            child: Text("Renvoyer"),
          )
        ],
      ),),
    );
  }
}
