import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerematontine/config/AppLifeCycle.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/screens/cotisations/payer_cotisation.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/tontine/tour_tontine.dart';
import 'package:gerematontine/screens/tontine/wallet_tontine.dart';
import 'package:gerematontine/services/fcm_service.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/server.dart';

class acceuil extends StatefulWidget {
  final Session listsession;
  const acceuil({super.key, required this.listsession});

  @override
  State<acceuil> createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {
  
  Future<void> monTour() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participants&action=mon_tour");
    final reponse=await post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "code_tontine":widget.listsession.code_tontine
        })).timeout(Duration(seconds: 5));

    if(reponse.statusCode==200){
      final tour=jsonDecode(reponse.body) as Map<String,dynamic>;
      if(tour['success']){
        Map<String,dynamic>donnee=tour['data'];
        if(donnee.isNotEmpty){
          setState(() {
            numeroTour=donnee['ordre'].toString();
            statut=donnee['statut'];
          });
        }
      }
    }else{
      print(reponse.statusCode);
    }
  }

  Future <void> totalCotisation() async{
    String? jwt=await widget.listsession.getSecureJwt();
    print("Le token est :$jwt");
    final url=Uri.parse("${adress}?ressource=cotisations&action=total_cotisation");
    final reponse=await post(url,headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $jwt"
    },body: jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    })).timeout(Duration(seconds: 5));

    if(reponse.statusCode==200){
      final total=jsonDecode(reponse.body) as Map<String,dynamic>;
      bool success=total['success'];
      if(success==true){
        setState(() {
          montantCotiser=total['data'].toString();
        });
      }
    }
  }

  //Future <void> totalPenalite() async{
    //final url=Uri.parse("${adress}?ressource=cotisations&action=total_penalite");
    //final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      //"code_participant":widget.listsession.code_participant,
      //"code_tontine":widget.listsession.code_tontine
    //})).timeout(Duration(seconds: 5));

    //if(reponse.statusCode==200){
    //  final total=jsonDecode(reponse.body) as Map<String,dynamic>;
    //  bool success=total['success'];
    //  if(success==true){
  //    setState(() {
  //      montantPenalite=total['data'].toString();
  //      if(double.parse(montantPenalite)>5000.00){
//        _critique=true;
//}
//});
//}
//}
  //}

  Future<void> tontineInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Vérifier si on a déjà des données en cache
    final cachedTontine = prefs.getString('tontine_info');
    final lastFetchStr = prefs.getString('tontine_last_fetch');
    DateTime? lastFetch = lastFetchStr != null ? DateTime.parse(lastFetchStr) : null;

    // Si cache existe et moins de 24h, utiliser cache
    if (cachedTontine != null && lastFetch != null && DateTime.now().difference(lastFetch).inHours < 24) {
      setState(() {
        tontine = Tontine.fromJson(jsonDecode(cachedTontine));
      });
      print("Données tontine chargées depuis le cache");
      return;
    }

    // Sinon, appel API
    String? jwt = await widget.listsession.getSecureJwt();
    final url = Uri.parse("${adress}?ressource=tontines&action=details_tontine");
    try {
      final reponse = await post(
        url,
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "code_tontine": widget.listsession.code_tontine
        }),
      ).timeout(Duration(seconds: 5));

      if (reponse.statusCode == 200) {
        final data = jsonDecode(reponse.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final tontineData = Tontine.fromJson(data['data']);
          setState(() {
            tontine = tontineData;
          });
          // Stocker dans le cache
          await prefs.setString('tontine_info', jsonEncode(data['data']));
          await prefs.setString('tontine_last_fetch', DateTime.now().toIso8601String());
          print("Données tontine chargées depuis l'API et mises en cache");
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => connexion_screen()),
                (route) => false);
      }
    } catch (e) {
      print("Erreur lors de la récupération des infos tontine: $e");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalCotisation();
    tontineInfo();
    monTour();
    envoyerToken();
    NotificationService.initialize();
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (tontine?.etat=="En attente" && messageAffich==false && widget.listsession.type_participant!="Organisateur") {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context){
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title:const Text("Oups !"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16.h,),
                      Text("Tontine incomplete. Partagez votre code tontine ou flasher votre QRCode pour inviter."),
                    ],
                  ),
                  actions: [
                    TextButton.icon(onPressed: (){
                      setState(() {
                        messageAffich=true;
                      });
                      Navigator.of(context).pop();
                    },style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent
                    ), label: Text("Compris",style: TextStyle(
                      color: Colors.white
                    ),),icon: Icon(Icons.verified,color: Colors.green,),)
                  ],
                );
              });
        }
      });
      print("Code tontine:${widget.listsession.code_tontine}");
    }
  }

  Future<void>initSharedPrefs()async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('nom',(widget.listsession.nom_participant).toString());
      prefs.setString('prenom',(widget.listsession.prenoms_participant).toString());
      prefs.setString('mobile',(widget.listsession.numero_participant).toString());
      prefs.setString('code_participant',(widget.listsession.code_participant).toString());
    });
  }

  Future<void>envoyerToken()async{
    final prefs=await SharedPreferences.getInstance();
    await FCMService.sendFCMTokenToServer(prefs.getString('fcm_token').toString(), widget.listsession.code_participant.toString());
  }

  bool?tokenEnvoyer;

  String montantCotiser="0";

  String montantPenalite="0";

  Tontine? tontine;

  String numeroTour="N/A";

  late int solvabilite = int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0;

  int statut=0;

  bool messageAffich=false;

  @override
  build(BuildContext context) {
    return VerificateurInactivite(
      tempsMaxInactivite: Duration(minutes: 5),
      delaisDepasse: () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>connexion_screen()), (route)=>false); },
      child: SafeArea(child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 145.w,right: 10.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text("Accueil",style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>parametre(listsession: widget.listsession,)));
                      }, icon: Icon(Icons.settings_outlined),color: Colors.black,
                      ),
                      IconButton(onPressed: (){
                        final secureStorage=FlutterSecureStorage();
                        setState(() {
                          secureStorage.delete(key: 'jwt_token');
                        });
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>connexion_screen()), (route)=>false);
                      }, icon: Icon(Icons.logout,color: Colors.black,))
                    ],
                  )
                ]
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: EdgeInsets.only(right: 5.0.w),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Row(
                    children: [
                      Text("Bienvenue, ${widget.listsession.nom_participant} ${widget.listsession.prenoms_participant}",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold
                      ),)
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>tourTontine(listsession: widget.listsession,  monTour: numeroTour, statut: statut,)));
                      },
                      child: Card(
                        elevation: 2,
                        color: Couleur.primaryBlue,
                        margin: EdgeInsets.all(10.w),
                        child: Padding(
                          padding: EdgeInsets.all(10.0.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mon numéro",style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(numeroTour,
                                    style: TextStyle(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                  Icon(statut==0?Icons.monetization_on_outlined:Icons.monetization_on,color: statut==0? Colors.red:Colors.green,size: 40.r,)
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    ),
                    Expanded(child: GestureDetector(
                      onTap: (){
                        setState(() {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>payer_cotisation(listsession: widget.listsession,)));
                        });
                      },
                      child: Card(
                        elevation: 2,
                        color: Couleur.primaryBlue,
                        margin: EdgeInsets.all(5.w),
                        child: Padding(
                          padding: EdgeInsets.all(15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mes cotisations",style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              TweenAnimationBuilder(tween: Tween(begin: 0,end:double.tryParse(montantCotiser) ?? 0.0), duration: Duration(seconds: 2), builder: (context,value,child){
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text("${value.toStringAsFixed(2)} FCFA",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    )
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Card(
                      elevation: 2,
                      color: Couleur.secondaryGreen,
                      margin: EdgeInsets.symmetric(horizontal:5.w),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Points de confiance",style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: solvabilite.toDouble()),
                                    duration: Duration(seconds: 2),
                                    builder: (context, value, child){
                                      return Text(
                                        "${value.toStringAsFixed(0)} Pts",
                                        style: TextStyle(
                                            fontSize: 35.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                      );
                                    }
                                )
                              ],
                            ),
                            SizedBox(
                              width: 125.w,
                            ),
                            Column(
                              children: [
                                IconButton(onPressed: (int.tryParse(widget.listsession.indice_solvabilite)??0)<75? null: (){
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Center(child: Text("Information"),),
                                      content: Text("Cette option sera bientôt disponible. Continuez à utiliser Djarra Finances"),
                                      actions: [
                                        Center(
                                          child: TextButton.icon(onPressed: (){
                                            Navigator.of(context).pop();
                                          },style: TextButton.styleFrom(
                                              backgroundColor: Couleur.secondaryGreen
                                          ), label: Text("Compris",style: TextStyle(
                                            color: Colors.white
                                          ),),icon: Icon(Icons.verified,color: Colors.white,),),
                                        )
                                      ],
                                    );
                                  });
                                }, icon: Icon(Icons.add_circle,color: Colors.white,size:30.r,)),
                                Icon(int.tryParse(widget.listsession.indice_solvabilite)!<50?Icons.warning:Icons.verified,color:Colors.white,size: 80.r,),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ma tontine",
                      style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    TextButton.icon(onPressed: tontine!= null
                        ? (){
                      final tontineData=tontine;
                      if(tontineData==null) {
                        return ;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>walletTontine(tontine: tontine!,listsession: widget.listsession, numeroTour: numeroTour )));
                    }:null,label: Text("CAISSE",style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),),icon: Icon(Icons.wallet,color:Couleur.primaryBlue,size: 30.r,),)
                  ],
                )
              ],
            ),
          ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Card(
                    elevation: 2,
                    color:Couleur.primaryBlue,//Color(0xFF3D0C94), // une nuance plus foncée du même violet,
                    margin: EdgeInsets.all(5.w),
                    child: Padding(
                        padding: EdgeInsets.all(10.0.w),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              widget.listsession.type_participant=="Organisateur"?
                              Row(
                                  children: [
                                    Text("Code tontine: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.code_tontine ?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ):
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(

                                  children: [
                                    Text("Nom tontine: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.nom_tontine ?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(

                                  children: [
                                    Text("Montant cotisation: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.montant_cotisation!=null ?"${tontine?.montant_cotisation} FCFA" :"N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                  children: [
                                    Text("Nombre participants: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.nombre_participant.toString() ?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(

                                  children: [
                                    Text("Fréquence cotisation: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.frequence?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(

                                  children: [
                                    Text("Fréquence paiement: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.frequence_paiement ?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                  children: [
                                    Text("Type de tontine: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.type?? "N/A",style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                  children: [
                                    Text("Date de création: ",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white
                                    ),),
                                    Text(tontine?.date_creation?? "N/A",style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),)
                                  ]
                              ),
                            ],
                          ),
                        )
                    ),
                  ),
                ),
              ),
            ),
        ],
      )
      ),
    );
  }
}
