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

class acceuil extends StatefulWidget {
  final Session listsession;
  const acceuil({super.key, required this.listsession});

  @override
  State<acceuil> createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {

  WalletTontine? wallet;
  List<Transactions>_listeTransac=[];

  bool _masque=true;
  bool optionAffiche=false;
  bool enCourtraitement=false;

  int notifCount = 0;
  List<Notifications>_listnotification=[];

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
        if(donnee!=null){
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

  @override
  void initState() {
    super.initState();
    tontineInfo();
    envoyerToken();
    recupererNotif();
    Timer.periodic(Duration(seconds: 3), (timer){
      recupererNotif();
    });
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
  String totalRetards="N/A";
  late int solvabilite = int.tryParse(widget.listsession.indice_solvabilite ?? "0") ?? 0;
  int statut=0;
  bool messageAffich=false;
  String?lienInvitationPartage;
  late String infoTour;

  TextEditingController lienPartage=TextEditingController();

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
                      height: 350.h,
                      child: Stack(
                        children: [
                          Positioned(
                          top: 0,
                          left: 10.w,
                          right: 10.w,
                            child: Container(
                              height: 160,
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
                          Positioned(
                            top: 140.h, // Position verticale
                            left: 25.w,
                            right: 25.w,
                            child: // ✅ CARTE VIRTUELLE STYLE MODERNE
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
                                                      "****  ****  ****  ${widget.listsession.code_tontine.substring(widget.listsession.code_tontine.length - 4)}",
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
                            ))
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
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
                    SizedBox(
                      height: 15.h,
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
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>retirer_gains(listsession:widget.listsession)));
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
                                        child: Icon(Icons.north_east, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Retirer",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>details_tontine(listsession: widget.listsession)));
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
                                        child: Icon(Icons.group, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Tontine",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>tourTontine(listsession: widget.listsession)));
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
                                        child: Icon(Icons.calendar_month, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Planning",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(width: 20.w,),
                                GestureDetector(
                                  onTap: (){
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
                                        child: Icon(Icons.query_stats_rounded, color: Couleur.primaryBlue, size: 28.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Vue globale",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
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
                          Text("Activité récente",style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold
                          ),),
                          SizedBox(
                            height: 10.h,
                          ),
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
                                        title: Text((widget.listsession.nom_participant==transac.nom && widget.listsession.prenoms_participant==transac.prenoms)? "Vous":transac.prenoms+" "+transac.nom, style: TextStyle(
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
                  ],
                                ),
                              ),
                ))
        ),
    );
  }
}