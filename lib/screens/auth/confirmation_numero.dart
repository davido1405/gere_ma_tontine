import 'dart:async';

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
      ScaffoldMessenger.of(context).showSnackBar(
        
        SnackBar(
          behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: Duration(seconds: 2),
            content: Container(
              padding: EdgeInsets.all(8.w),
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.r)
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,color: Colors.white,size: 20.r,),
                  SizedBox(width: 20.w,),
                  Text("Erreur: Numéro de téléphone non trouvé")
                ],
              ),))
      );
    }

    print("Envoi OTP vers: $numero");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            dismissDirection: DismissDirection.horizontal,
            duration: Duration(seconds: 3),
            content: Container(
              padding: EdgeInsets.all(8.w),
              height: 80.h,
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12.r),
                boxShadow: null
              ),
              child: Row(
                children: [
                  Icon(Icons.pending,color: Colors.white,size: 20.r,),
                  SizedBox(width: 20.w,),
                  Text("Envoi OTP vers: $numero")
                ],
              ),))
    );

    await _auth.verifyPhoneNumber(
      phoneNumber: numero, // ton numéro complet
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        //Definirpin();
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Erreur OTP: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        print("OTP envoyé ID: $_verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP incorrect")),
                  );
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
