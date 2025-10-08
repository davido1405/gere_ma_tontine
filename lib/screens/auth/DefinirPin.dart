import 'dart:convert';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
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

  late Session listsession;
  bool confirmation=false;

  Future<void> verifierLien(String token) async {
    try {
      final url = Uri.parse("$adress?ressource=tontines&action=verifierInvitation");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultat = jsonDecode(response.body);
        if (resultat['success']) {
          final data = resultat['data'];
          // On peut stocker certaines infos si besoin
          listsession.setCodeTontine(data['code_tontine']);
        } else {
          _showErreur(resultat['message'] ?? "Lien invalide ou expiré");
        }
      } else {
        _showErreur("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      _showErreur("Une erreur est survenue: $e");
    }
  }

  void _showErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  bool _isLoading = false; // AJOUT 1: État de chargement
  // AJOUT 5: Validation du code tontine
    bool _isValidTontineCode(String code) {
      // Ajustez selon le format de vos codes tontine
      return code.isNotEmpty && code.length >= 6;
    }
  //Participer si lien d'invitation
  Future<void> participerTontine() async {
    if (!_isValidTontineCode(listsession.code_tontine)) {
      _showErrorDialog("Code tontine invalide", "Veuillez vérifier le format du code");
      return;
    }
    // AJOUT 6: Gestion du loading state
    setState(() {
      _isLoading = true;
    });

    try {
      String? jwt = await listsession.getSecureJwt();
      final url = Uri.parse("${adress}?ressource=participations&action=participer");
      final response = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $jwt",
            "content-Type": "application/json",
          },
          body: jsonEncode({
            "code_participant": listsession.code_participant,
            "code_tontine": listsession.code_tontine
          }));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        bool success = data['success'];
        if (success) {
          Future.delayed(Duration(milliseconds: 300),(){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => dashboard(listsession: listsession)),
                    (route) => false);
          });
        } else {
          _showErrorDialog("Erreur", "Une erreur s'est produite veuillez réesayer plus tard ou contacter le service technique.");
        }
      } else {
        _showErrorDialog("Erreur serveur", "Une erreur s'est produite côté serveur. Veuillez réessayer plus tard");
      }
    } catch (e) {
      _showErrorDialog("Erreur", "Une erreur inattendue s'est produite");
    } finally {
      // AJOUT 7: Toujours arrêter le loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  // AJOUT 8: Méthode factorisant l'affichage des erreurs
  void _showErrorDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(backgroundColor: Couleur.secondaryGreen),
                  label: Text("Compris", style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.verified, color: Colors.white))
            ],
          );
        });
  }

  // AJOUT 9: Style factorisant pour les boutons
  ButtonStyle get _buttonStyle => TextButton.styleFrom(
    backgroundColor: Couleur.primaryBlue,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  );

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
          listsession=Session.fromJson(finalUser);
        });
        await listsession.secureJwt();
        //Verifier s'il y'a un lien d'invitation
        if(prefs.getString('token_invitation')!=null){
          String? token_invitation=prefs.getString('token_invitation');
          await verifierLien(token_invitation!);
          await participerTontine();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: listsession,)), (route)=>false);
        }else{
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>participer(listsession: listsession,)), (route)=>false);
        }
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
