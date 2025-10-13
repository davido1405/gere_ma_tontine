import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';
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
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
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
    final reponse=await post(url,headers: {"Content-Type":"application/json",
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

  Future<void> tontineInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Charger immédiatement les données du cache (affichage rapide)
    final cachedTontine = prefs.getString('tontine_info');
    if (cachedTontine != null) {
      setState(() {
        tontine = Tontine.fromJson(jsonDecode(cachedTontine));
      });
      print("✅ Tontine chargée depuis le cache");
    }

    // Ensuite, vérifier s'il y a une mise à jour côté serveur
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
      ).timeout(const Duration(seconds: 5));

      if (reponse.statusCode == 200) {
        final data = jsonDecode(reponse.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final tontineData = Tontine.fromJson(data['data']);

          // Comparer les états (ou autre champ clé)
          if (tontine == null || tontine!.etat != tontineData.etat) {
            setState(() {
              tontine = tontineData;
            });

            // Mettre à jour le cache
            await prefs.setString('tontine_info', jsonEncode(data['data']));
            await prefs.setString('tontine_last_fetch', DateTime.now().toIso8601String());

            print("🔄 Cache mis à jour (changement d'état détecté)");
          } else {
            print("✅ Aucune modification détectée");
          }
        }
      }
    } catch (e) {
      print("⚠️ Erreur lors de la vérification des infos tontine: $e");
    }
  }


  Future<void>lienInvitation()async{
    String? jwt = await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=inviter");
    final reponse=await post(url,headers: {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json"
    },body: jsonEncode({
      'code_tontine': widget.listsession.code_tontine,
      'code_participant':widget.listsession.code_participant
    }));
    if(reponse.statusCode==200){
      final resultat=jsonDecode(reponse.body);
      print(reponse.body);
      if(resultat['data']!=null){
        setState(() {
          lienInvitationPartage=resultat['data']['lien'];
        });
        print("✅ Lien généré : $lienInvitationPartage");
      }else{
        print("Y'a rien dans data");
      }
    }
  }

  //RElancer les tours
  Future<bool>relancer()async{
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Center(child: Text("Relance des tour")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(colorFilter: ColorFilter.mode(Couleur.primaryBlue, BlendMode.srcATop),child: Lottie.asset("assets/animations/Icon Set - Setting.json",width: 150.w,height: 150.h),),
            SizedBox(height: 15.h,),
            Text("Génération des tours...")
          ],
        ),
      );
    });
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=liste_tours");
    final response=await post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          'code_tontine':widget.listsession.code_tontine,
          'relancer':true
        }
    ));
    //Fermer le premier dialogue
    Navigator.of(context).pop();

    if(response.statusCode==200){
      final donnee=jsonDecode(response.body) as Map<String,dynamic>;
      bool success=donnee['success'];
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Center(child: Text("Statut")),
          content: success? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/animations/Approve.json",width: 150.w,height: 150.h),
              SizedBox(height: 10.h,),
              Text(donnee['message'])
            ],
          ):Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/animations/Sign for error _ Flat style.json",width: 150.w,height: 150.h),
              SizedBox(height: 10.h,),
              Text("Oups! Une erreur s'est produite, veuillez réessayer.")
            ],
          ),
          actions: [
            Center(child: TextButton.icon(onPressed: (){
              if(success){
                setState(() {
                  tontine?.etat="En cours";
                });
                monTour();
                Navigator.of(context).pop();
              }else{
                Navigator.of(context).pop();
              }
            }, label: Text("Compris", style: TextStyle(color: Colors.white),),icon: Icon(Icons.verified,color: Colors.white,),style: TextButton.styleFrom(
              backgroundColor: Couleur.secondaryGreen
            ),),)
          ],
        );
      });
    }else{
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Center(child: Text("Information")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Une erreur serveur s'est produite, veuillez reéssayer plus tard. Merci",overflow: TextOverflow.ellipsis,maxLines: 2,),
            ],
          ),
          actions: [
            Center(
              child: TextButton.icon(onPressed: (){
                Navigator.of(context).pop();
              },style: TextButton.styleFrom(
                  backgroundColor: Couleur.secondaryGreen
              ), label: Text("Compris",style: TextStyle(color: Colors.white),),icon: Icon(Icons.verified,color: Colors.white,),),
            )
          ],
        );
      });
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    totalCotisation();
    tontineInfo();
    monTour();
    envoyerToken();
    NotificationService.initialize();
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

  bool? tokenEnvoyer;
  String montantCotiser="0";
  String montantPenalite="0";
  Tontine? tontine;
  String numeroTour="N/A";
  late int solvabilite = int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0;
  int statut=0;
  bool messageAffich=false;
  String?lienInvitationPartage;
  late String infoTour;

  TextEditingController lienPartage=TextEditingController();

  @override
  build(BuildContext context) {
    return VerificateurInactivite(
        tempsMaxInactivite: Duration(minutes: 5),
        delaisDepasse: () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>connexion_screen()), (route)=>false);
        },
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
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.only(right: 5.0.w),
              child: RefreshIndicator(
                onRefresh: () async {
                  tontineInfo();
                },
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
                            Navigator.push(context, MaterialPageRoute(builder: (_)=>tourTontine(listsession: widget.listsession, monTour: numeroTour, statut: statut,)));
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
                                  ),),
                                  SizedBox(height: 5.h),
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
                                  SizedBox(height: 5.h)
                                ],
                              ),
                            ),
                          ),
                        )),
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
                                  ),),
                                  SizedBox(height: 20.h),
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
                        ))
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
                                    ),),
                                    SizedBox(height: 10.h),
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
                                SizedBox(width: 125.w),
                                Column(
                                  children: [
                                    IconButton(
                                        onPressed: (int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0) < 75 ? null : (){
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
                                        },
                                        icon: Icon(Icons.add_circle,color: Colors.white,size:30.r,)
                                    ),
                                    // CORRECTION PRINCIPALE ICI - ligne 442
                                    Icon(
                                      (int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0) < 50
                                          ? Icons.warning
                                          : Icons.verified,
                                      color: Colors.white,
                                      size: 80.r,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
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
                      if (widget.listsession.type_participant == "Organisateur")
                        TextButton.icon(
                          onPressed: (tontine?.etat.toLowerCase() ?? "")== "terminée" ?() async {
                            if( await relancer()){
                              setState(() {
                                tontine!.etat="En cours";
                              });
                              monTour();
                            }
                          }:null ,
                          label: Text("Relancer",style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),),
                          icon: Icon(Icons.replay,color: Couleur.primaryBlue,size: 30.r,),
                        ),
                      TextButton.icon(
                        onPressed: tontine != null ? (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>walletTontine(tontine: tontine!, listsession: widget.listsession, numeroTour: numeroTour)));
                        } : null,
                        label: Text("CAISSE",style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),),
                        icon: Icon(Icons.wallet,color: Couleur.primaryBlue,size: 30.r,),
                      )
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
                    color: Couleur.primaryBlue,
                    margin: EdgeInsets.all(5.w),
                    child: Padding(
                        padding: EdgeInsets.all(10.0.w),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.h),
                              if(widget.listsession.type_participant == "Organisateur")
                                Row(children: [
                                  Text("Code tontine: ",style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.white
                                  ),),
                                  Text(tontine?.code_tontine ?? "N/A",style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ])
                              else
                                SizedBox(height: 5.h),
                              Row(children: [
                                Text("Nom tontine: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.nom_tontine ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Montant cotisation: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.montant_cotisation != null ? "${tontine!.montant_cotisation} FCFA" : "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Nombre participants: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.nombre_participant?.toString() ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Fréquence cotisation: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.frequence ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Fréquence paiement: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.frequence_paiement ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Type de tontine: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.type ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(height: 5.h),
                              Row(children: [
                                Text("Date de création: ",style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white
                                ),),
                                Text(tontine?.date_creation ?? "N/A",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]),
                              SizedBox(
                                height: 10.h,
                              ),
                              if (widget.listsession.type_participant=="Organisateur")
                                Center(child: TextButton.icon(onPressed: () async {
                                  await lienInvitation();
                                  Share.share("Rejoins ma tontine sur Djarra Finances 🚀: $lienInvitationPartage",subject: "Invitation à rejoindre une tontine");
                                },style: TextButton.styleFrom(
                                  backgroundColor: Couleur.accentOrange
                                ), label: Text("Inviter un ami",style: TextStyle(
                                  color: Colors.white
                                ),),icon: Icon(Icons.share,color: Colors.white,),),)
                            ],
                          ),
                        )
                    ),
                  ),
                ),
              ),
            ),
          ],
        ))
    );
  }
}