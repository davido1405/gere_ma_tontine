import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/config/AppLifeCycle.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/screens/dashboard/participer.dart';
import 'package:gerematontine/screens/notifications/liste_notifications.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/participant/retirer_gains.dart';
import 'package:gerematontine/screens/participant/wallet_participant.dart';
import 'package:gerematontine/screens/tontine/details_tontine.dart';
import 'package:gerematontine/screens/tontine/tour_tontine.dart';
import 'package:gerematontine/screens/tontine/vue_globale.dart';
import 'package:gerematontine/services/fcm_service.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/server.dart';
import '../../models/notification.dart';
import '../../models/transactions.dart';
import '../../models/wallet_tontine.dart';
import '../cotisations/payer_cotisation.dart';
import '../tontine/creer_tontine.dart';

class acceuil extends StatefulWidget {
  final Session listsession;
  const acceuil({super.key, required this.listsession});

  @override
  State<acceuil> createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {

  @override
  void initState() {
    super.initState();
    tontineInfo();
    envoyerToken();
    recupererNotif();
    transacs();
    recupererWallet();
    Timer.periodic(Duration(seconds: 3), (timer){
      recupererNotif();
    });
    NotificationService.initialize();
  }

  WalletTontine? wallet;
  List<Transactions>_listeTransac=[];
  bool _masque=true;
  bool optionAffiche=false;
  bool enCourtraitement=false;
  int notifCount = 0;
  List<Notifications>_listnotification=[];
  bool? tokenEnvoyer;
  String montantCotiser="0";
  String montantPenalite="0";
  Tontine? tontine;
  String numeroTour="N/A";
  String totalRetards="N/A";
  late int solvabilite = int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0;
  int statut=0;
  bool messageAffich=false;
  String?lienInvitationPartage;
  late String infoTour;
  TextEditingController lienPartage=TextEditingController();

  //Recupérer le wallet
  Future<void>recupererWallet() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=wallet_infos");
    final reponse=await post(url,headers: {'Authorization':'Bearer $jwt','content-Type':'application/json'},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
        }));
    if(reponse.statusCode==200){
      Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']==true){
        var infos=data['data'];
        if(infos!=null){
          setState(() {
            wallet=WalletTontine.fromJson(infos);
          });
        }
      }
    }
  }
  //Récupérer la liste des transactions
  Future<void>transacs() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=transactions");
    final response=await post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(response.body);
      if(data['success']==true){
        final List<dynamic>donnee=data['data'];
        if(donnee.isNotEmpty){
          setState(() {
            _listeTransac=donnee.map((donnee)=>Transactions.fromJson(donnee)).toList();
          });
        }else{
          setState(() {
            _listeTransac=[];
          });
        }
      }
    }
  }
  //Récupérer les informations de la tontine
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
  //Générer le lien d'invitation
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
  //Récupérer toutes les notifications
  Future<void>recupererNotif()async {
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=notifications&action=lister_notification");
    final reponse=await post(
        url,
        headers: {
          "content-Type":"application/json",
          "Authorization":"Bearer $jwt"
        },body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "filtre":"Non lu"
        })).timeout(Duration(seconds: 30));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success && data['data']!=null){
        List<dynamic>notifs=data['data'];

        if(!mounted) return;
        setState(() {
          _listnotification=notifs.map((notifs)=>Notifications.fromJson(notifs)).toList();
          // ✅ Mets à jour ton compteur du badge
          notifCount = _listnotification.length;
        });
      }else{
        // ✅ Cas où il n'y a AUCUNE notif
        if(!mounted)return;
        setState(() {
          notifCount = 0; // ➝ ton badge va afficher 0
        });
      }
    }else{
      print("Erreur serveur : ${reponse.statusCode}");
    }
  }
  //Récupérer les informations de l'utilisateur dans le cache
  Future<void>initSharedPrefs()async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('nom',(widget.listsession.nom_participant).toString());
      prefs.setString('prenom',(widget.listsession.prenoms_participant).toString());
      prefs.setString('mobile',(widget.listsession.numero_participant).toString());
      prefs.setString('code_participant',(widget.listsession.code_participant).toString());
    });
  }
  //Envoyer le token utilisateur pour reception des notifications
  Future<void>envoyerToken()async{
    final prefs=await SharedPreferences.getInstance();
    await FCMService.sendFCMTokenToServer(prefs.getString('fcm_token').toString(), widget.listsession.code_participant.toString());
  }


  @override
  build(BuildContext context) {
    return Scaffold(
      body: VerificateurInactivite(
            tempsMaxInactivite: Duration(minutes: 5),
            delaisDepasse: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>connexion_screen()), (route)=>false);
            },
            child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: ()async{
                    recupererWallet();
                    recupererNotif();
                },
                  child: SingleChildScrollView(

                    physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: widget.listsession.code_tontine!="default code"? 415.h:610.h,
                      child: Stack(
                        children: [
                          Positioned(
                          top: 0,
                          left: 10.w,
                          right: 10.w,
                            child: Container(
                              height: 200.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.r),bottomRight: Radius.circular(12.r)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.0.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(child: Row(children: [
                                            Image.asset("assets/djarra_finances_v1ico.png",width: 45.w,height: 45.h,),
                                            SizedBox(width: 10.w,),
                                            Text("Djarra Finances", style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),),

                                          ],),),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>notifications(listsession: widget.listsession)));
                                                },
                                                child: Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(12.r)
                                                  ),
                                                  child:
                                                     Center(
                                                       child: badges.Badge(
                                                        badgeStyle: badges.BadgeStyle(
                                                          badgeColor: Colors.red,
                                                        ), badgeContent: Text("${notifCount}",style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold),),child: Icon(Icons.notifications),),
                                                     ),
                                                  ),
                                              ),
                                              SizedBox(width: 20.w,),
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>parametre(listsession: widget.listsession)));
                                                },
                                                child: Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(12.r)
                                                  ),
                                                  child:
                                                  Center(
                                                    child: Icon(Icons.settings_outlined),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),]),
                                      SizedBox(height: 15.h,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Salut 👋, ",style: TextStyle(fontSize: 15.sp),),
                                          Text("${widget.listsession.nom_participant} ${widget.listsession.prenoms_participant}",style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25.sp),)
                                        ],
                                      ),]),
                              ),
                            ),
                          ),
                          widget.listsession.code_tontine=="default code"?
                            Positioned(
                                top: 210.h, // Position verticale
                                left: 25.w,
                                right: 25.w,
                                child: // ✅ CARTE VIRTUELLE STYLE MODERNE
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Bienvenue sur Djarra 🚀",
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                    Text("Ta plateforme pour gérer ton argent éfficacement",style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: SizedBox(
                                        height: 250.h,
                                        width: 410.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Couleur.primaryBlue,
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 4.w,
                                                child: Container(
                                                  height: 250.h,
                                                  width: 410.w,
                                                  padding: EdgeInsets.all(8.w),  // ✅ Padding augmenté
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20.r),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0.w),
                                                    child: Column(  // ✅ Column au lieu de Row pour mieux organiser
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // Badge "LANCE-TOI"
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Couleur.primaryBlue,
                                                            borderRadius: BorderRadius.circular(20.r),
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                                          child: Text(
                                                            "LANCE-TOI",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(height: 16.h),

                                                        // Contenu principal
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // Icône
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  colors: [Couleur.primaryBlue, Couleur.secondaryGreen],
                                                                  begin: Alignment.topLeft,
                                                                  end: Alignment.bottomRight,
                                                                ),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.all(12.r),
                                                                child: Icon(
                                                                  Icons.group_outlined,
                                                                  color: Colors.white,
                                                                  size: 28.sp,
                                                                ),
                                                              ),
                                                            ),

                                                            SizedBox(width: 16.w),

                                                            // ✅ Texte avec Expanded
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    "Tontine",
                                                                    style: TextStyle(
                                                                      fontSize: 20.sp,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 6.h),
                                                                  Text(
                                                                    "Epargne avec tes amis, recevez à tour de rôle. Simple et sans tracas !",
                                                                    style: TextStyle(
                                                                      fontSize: 13.sp,
                                                                      color: Colors.grey[700],
                                                                      height: 1.4,
                                                                    ),
                                                                    maxLines: 3,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  SizedBox(height: 12.h),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "✨",
                                                                        style: TextStyle(fontSize: 16.sp),
                                                                      ),
                                                                      SizedBox(width: 4.w),
                                                                      Flexible(  // ✅ Flexible pour éviter overflow
                                                                        child: Text(
                                                                          "Commence ici - Notre 1er service",
                                                                          style: TextStyle(
                                                                            fontSize: 12.sp,
                                                                            color: Couleur.primaryBlue,
                                                                            fontWeight: FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(height: 12.h,),  // ✅ Pousse les boutons en bas

                                                        // Boutons CTA
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                                                          child: Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:(){
                                                                  if(mounted){
                                                                    Navigator.push(context,
                                                                        MaterialPageRoute(builder: (context) => creer_tontine(listsession: widget.listsession)));
                                                                  }
                                                                },
                                                                child: Container(
                                                                  height:45.h,
                                                                  width: 150.w,
                                                                  decoration:BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10.r),
                                                                      gradient: LinearGradient(colors: [Couleur.primaryBlue,Couleur.secondaryGreen],begin: Alignment.centerLeft,end: Alignment.centerRight)
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    mainAxisSize:MainAxisSize.min,
                                                                    children: [
                                                                      Icon(Icons.add,color: Colors.white,),
                                                                      Text("Créer ma tontine",
                                                                        style: TextStyle(
                                                                          fontSize: 14.sp,
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),)
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 14.w),
                                                              GestureDetector(
                                                                onTap:(){
                                                                  if(mounted){
                                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>participer(listsession: widget.listsession)));
                                                                  }
                                                                },
                                                                child: Container(
                                                                  height:45.h,
                                                                  width: 150.w,
                                                                  decoration:BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10.r),
                                                                    border: Border(
                                                                      top: BorderSide(color: Couleur.secondaryGreen,
                                                                          width: 1.w,
                                                                          style: BorderStyle.solid),
                                                                      bottom: BorderSide(color: Couleur.secondaryGreen,
                                                                          width: 1.w,
                                                                          style: BorderStyle.solid),
                                                                      left: BorderSide(color: Couleur.secondaryGreen,
                                                                          width: 1.w,
                                                                          style: BorderStyle.solid),
                                                                      right: BorderSide(color: Couleur.secondaryGreen,
                                                                          width: 1.w,
                                                                          style: BorderStyle.solid),

                                                                    ),
                                                                      ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    mainAxisSize:MainAxisSize.min,
                                                                    children: [
                                                                      Icon(Icons.qr_code_scanner,color: Couleur.secondaryGreen,),
                                                                      Text("Rejoindre",
                                                                        style: TextStyle(
                                                                          fontSize: 14.sp,
                                                                          color: Couleur.secondaryGreen,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),)
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Text("Bientôt sur Djarra 🚀",
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text("Utilises la tontine pour être éligible aux prochains services",style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),),
                                    ),
                                  ],
                                )
                            ):
                          Positioned(
                            top: 140.h, // Position verticale
                            left: 25.w,
                            right: 25.w,
                            child: // ✅ CARTE VIRTUELLE STYLE MODERNE
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    // ✅ Dégradé inspiré de votre logo (bleu Djarra)
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Couleur.primaryBlue,  // Bleu moyen
                                          Couleur.secondaryGreen,  // Bleu foncé
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF0EA5E9).withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // ✅ Cercles décoratifs (effet carte bancaire)
                                        Positioned(
                                          top: -50,
                                          right: -50,
                                          child: Container(
                                            width: 150.w,
                                            height: 150.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.1),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -30,
                                          left: -30,
                                          child: Container(
                                            width: 100.w,
                                            height: 100.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.08),
                                            ),
                                          ),
                                        ),

                                        // Contenu principal
                                        Padding(
                                          padding: EdgeInsets.all(20.w),
                                          child: Row(
                                            children: [
                                              // Colonne texte (65%)
                                              Expanded(
                                                flex: 65,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Header avec logo mini
                                                    Row(
                                                      children: [
                                                        // Mini logo ou icône
                                                        Container(
                                                          padding: EdgeInsets.all(6.w),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(8.r),
                                                          ),
                                                          child: Icon(
                                                            Icons.account_balance_wallet,
                                                            color: Colors.white,
                                                            size: 16.sp,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Text(
                                                          "TONTINE",
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white.withOpacity(0.9),
                                                            letterSpacing: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 20.h),

                                                    // Label
                                                    Text(
                                                      "Solde de la caisse",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white.withOpacity(0.8),
                                                      ),
                                                    ),

                                                    SizedBox(height: 8.h),

                                                    // Montant avec masquage
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: _masque
                                                              ? Text(
                                                            "•••  •••  •••",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 28.sp,
                                                              fontWeight: FontWeight.bold,
                                                              letterSpacing: 4,
                                                            ),
                                                          )
                                                              : wallet != null
                                                              ? TweenAnimationBuilder(
                                                              tween: Tween(
                                                                  begin: 0.0,
                                                                  end: double.parse(wallet!.solde_tontine.toString())
                                                              ),
                                                              duration: Duration(seconds: 2),
                                                              builder: (context, double value, child) {
                                                                return Text(
                                                                  "${value.toStringAsFixed(0)} FCFA",
                                                                  style: TextStyle(
                                                                    fontSize: 28.sp,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.white,
                                                                    shadows: [
                                                                      Shadow(
                                                                        color: Colors.black.withOpacity(0.2),
                                                                        offset: Offset(0, 2),
                                                                        blurRadius: 4,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                );
                                                              }
                                                          )
                                                              : Text(
                                                            "0 FCFA",
                                                            style: TextStyle(
                                                              fontSize: 26.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 12.w),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _masque = !_masque;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(8.w),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8.r),
                                                            ),
                                                            child: Icon(
                                                              _masque ? Icons.visibility_off : Icons.visibility,
                                                              color: Colors.white,
                                                              size: 20.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 16.h),

                                                    // Info supplémentaire (numéro de carte fictif)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          widget.listsession.code_tontine != null &&
                                                              widget.listsession.code_tontine != "default code" &&
                                                              widget.listsession.code_tontine.length >= 4
                                                              ? "****  ****  ****  ${widget.listsession.code_tontine.substring(widget.listsession.code_tontine.length - 4)}"
                                                              : "****  ****  ****  ****",  // Valeur par défaut
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.white.withOpacity(0.7),
                                                            letterSpacing: 2,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        // Badge KYC
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(12.r),
                                                          ),
                                                          child: Text(
                                                            widget.listsession.niveau_kyc ?? 'LOADING',
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>payer_cotisation(listsession:widget.listsession)));
                                        }, label: Text("Payer ma cotisation",style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),),icon: Icon(Icons.payment),style: OutlinedButton.styleFrom(
                                            backgroundColor: Couleur.primaryBlue,
                                            iconColor: Colors.white,
                                            iconSize: 30.r
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 25.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Actions rapides",style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold
                          ),),
                          SizedBox(height: 15.h,),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                              GestureDetector(
                              onTap: (){
                                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>wallet_participant(listsession:widget.listsession)));
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.wallet, color: Couleur.primaryBlue, size: 28.sp),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Mon wallet",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                SizedBox(width: 20.w,),GestureDetector(
                                  onTap:widget.listsession.code_tontine=="default code"?null: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>retirer_gains(listsession:widget.listsession)));
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: widget.listsession.code_tontine=="default code"?Couleur.iconInactive:Colors.white,
                                          borderRadius: BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.north_east, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Retirer",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: widget.listsession.code_tontine=="default code"?Couleur.iconInactive:Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap: widget.listsession.code_tontine=="default code"? null:(){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>details_tontine(listsession: widget.listsession)));
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: widget.listsession.code_tontine=="default code"?Couleur.iconInactive:Colors.white,
                                          borderRadius: BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.group, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Tontine",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color:widget.listsession.code_tontine=="default code"?Couleur.iconInactive: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap:widget.listsession.code_tontine=="default code"?null: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>tourTontine(listsession: widget.listsession)));
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: widget.listsession.code_tontine=="default code"?Couleur.iconInactive:Colors.white,
                                          borderRadius: BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.calendar_month, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Planning",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: widget.listsession.code_tontine=="default code"?Couleur.iconInactive:Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap:widget.listsession.code_tontine=="default code"?null: (){
                                    if(mounted){
                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>VueGlobale(listsession:widget.listsession)));
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: widget.listsession.code_tontine=="default code"?Couleur.mediumGray:Colors.white,
                                          borderRadius: BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.query_stats_rounded, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Vue globale",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: widget.listsession.code_tontine=="default code"?Couleur.mediumGray:Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                ],
                            ),
                          ),SizedBox(
                            height: 15.h,
                          ),
                          widget.listsession.code_tontine!="default code"?
                          Text("Activité récente",style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold
                          ),):SizedBox(height: 0,),
                          SizedBox(
                            height: 10.h,
                          ),
                          widget.listsession.code_tontine=="default code"?
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Bande de couleur à gauche
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 5.w,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Couleur.primaryBlue, Couleur.secondaryGreen],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        bottomLeft: Radius.circular(20.r),
                                      ),
                                    ),
                                  ),
                                ),

                                // Contenu
                                Padding(
                                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 20.w, 20.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFFF3E0),
                                                  Color(0xFFFFE0B2),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              Icons.tips_and_updates,
                                              color: Color(0xFFFF9800),
                                              size: 22.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            "Astuce",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Couleur.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        "Commence par une petite tontine entre amis pour tester !",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[700],
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Couleur.secondaryGreen,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              "Simple, rapide et sans risque",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Couleur.secondaryGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ):
                            SizedBox(
                                height:300.h,
                                width: double.maxFinite,
                                child: _listeTransac.isEmpty ?
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ColorFiltered(colorFilter: ColorFilter.mode(Couleur.primaryBlue, BlendMode.srcATop),
                                        child: Lottie.asset("assets/animations/lottieflow-ecommerce-14-7-000000-easey.json",width: 150.w,height: 150.h),),
                                      SizedBox(height: 15.h,),
                                      Text("Vos transactions apparaîtront ici",
                                        style: TextStyle(color: Colors.grey[600]),)
                                    ],
                                  ),
                                ): ListView.builder(
                                    itemCount: _listeTransac.length,
                                    itemBuilder: (context,index){
                                      final Transactions transac=_listeTransac[index];
                                      return GestureDetector(
                                        onTap: (){
                                          showDialog(context: context, builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Center(child: Text("Détails de transaction",style: TextStyle(
                                                  fontSize: 15.sp
                                              ),)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Nom :${transac.nom}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Prénoms :${transac.prenoms}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Type de transaction :${transac.type_transaction}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Montant de transaction :${transac.montant_transaction}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Date de transaction :${transac.date_transaction}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Mode de paiement :${transac.mode_paiement}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                  Text("Statut: ${transac.statut_paiement}",style: TextStyle(
                                                      fontSize: 15.sp
                                                  ),),
                                                ],
                                              ),
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
                                        child: ListTile(
                                          title: Text((widget.listsession.nom_participant==transac.nom && widget.listsession.prenoms_participant==transac.prenoms)? "Vous":"${transac.prenoms} ${transac.nom}", style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold
                                          ),),
                                          subtitle: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(transac.type_transaction,style: TextStyle(
                                                      fontSize: 14.sp
                                                  ),),
                                                  Text(transac.date_transaction,style: TextStyle(
                                                      fontSize: 14.sp
                                                  ),)
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(transac.type_transaction!="Retrait" ? "+ ${transac.montant_transaction}":"- ${transac.montant_transaction}",style: TextStyle(
                                                          color:(transac.type_transaction=="Retrait")?  Colors.red:Colors.green,
                                                          fontWeight: FontWeight.bold
                                                      ),),
                                                      Text(transac.statut_paiement)
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10.h,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Icon(transac.type_transaction!="Retrait"? Icons.arrow_outward:Icons.arrow_downward,color:transac.type_transaction!="Retrait"? Colors.green:Colors.red,size: 20.r)
                                                    ],
                                                  )
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      );
                                    })
                            )
                        ],
                      ),
                    ),
                  ],),
                  ),
                ))
        ),
    );
  }
}