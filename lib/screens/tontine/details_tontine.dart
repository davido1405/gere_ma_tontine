import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/membres.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';
import '../../models/beneficiare.dart';
import '../../models/tontines.dart';

class details_tontine extends StatefulWidget {
  final Session listsession;
  const details_tontine({super.key, required this.listsession});

  @override
  State<details_tontine> createState() => _details_tontineState();
}

class _details_tontineState extends State<details_tontine> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargerMembres();
    _controllerLotti=AnimationController(duration: Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose(){
    _controllerLotti.dispose();
    super.dispose();
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
  late AnimationController _controllerLotti;

  late List<Membre>membres=[];

  List<Beneficiare> _listOrdre=[];

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

  Future<void>verifierTour()async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participants&action=verifierTour");
    final response=await post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>donnee=jsonDecode(response.body);
      if(donnee['success']==true){
        var tour=donnee['data'];
        if(tour!=null && mounted){
          setState(() {
            nomBeneficiare=tour['nom_participant'];
            prenomsBeneficiare=tour['prenoms_participant'];
            datePaiement=tour['date_tour'];
          });
        }
      }
    }
  }

  //Liste des bénéficiares
  Future<void>listeBeneficiare() async{
    if(!mounted) return;
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=ordre_paiement");
    final response=await post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
        }));
    if(!mounted) return;
    if(response.statusCode==200){
      final Map<String,dynamic>donnee=jsonDecode(response.body);
      bool succes=donnee['success'];
      if(succes){
        List<dynamic>resultats=donnee['data'];
        if(resultats!=null){
          if(!mounted) return;
          setState(() {
            _listOrdre=(resultats).map((resultats)=>Beneficiare.fromJson(resultats)).toList();
          });
        }else{
          _listOrdre=[];
        }
      }
    }
  }

  late String nomBeneficiare="N/A";
  late String prenomsBeneficiare="N/A";
  late String datePaiement="N/A";

  Future<void>chargerMembres()async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=lister_membres");
    final reponse=await http.post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success){
        List<dynamic>toutMemnres=data['data'];
        setState(() {
          membres=toutMemnres.map((toutMemnres)=>Membre.fromJson(toutMemnres)).toList();
        });
      }
    }
  }

  Future<void>envoyerRappelCotisation()async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=notifications&action=envoyer_rappel_cotisation");
    final reponse=await http.post(
        url,
        headers: {
          "Content-Type":"Application/json",
          "Authorization":"Bearer $jwt"
        },body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine,
          "type_notification":"Rappel de cotisation"
        }));
    if(reponse.statusCode==200){
      var data=jsonDecode(reponse.body) as Map<String,dynamic>;
      bool success=data['success'];
      if(success){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Statut notification"),),
            content: Text(data['message']),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                },style: TextButton.styleFrom(
                backgroundColor: Couleur.secondaryGreen
                ),label: Text("Compris",style: TextStyle(
                  color: Colors.white
                ),),icon: Icon(Icons.verified,color: Colors.white,),),
              )
            ],
          );
        });
      }else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Information !"),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Center(
                child: Lottie.asset('assets/animations/Sign for error _ Flat style.json',
                    width: 150.w,
                    height: 150.h,
                    repeat: true,
                    controller: _controllerLotti,
                    onLoaded: (composition){
                      _controllerLotti.forward();
                    }),
              ),
              Text(data['message']),
            ],),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                  _controllerLotti.reset();
                },style: TextButton.styleFrom(
                    backgroundColor: Couleur.secondaryGreen
                ), label: Text("Compris",style: TextStyle(color: Colors.white),),icon: Icon(Icons.verified,color: Colors.white,),),
              )
            ],
          );
        });
      }
    }else{
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Center(child: Text("Statut notification"),),
          content: Text("Une erreur est survenu côté serveur"),
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
  }

  contacterParticipant(String numero){
    final String message=Uri.encodeComponent("Bonjour, nous participons à la même tontine sur Djarra Finances.");
    final String url="https://wa.me/$numero?text=$message";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Détails tontine",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold),),),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ()async { await monTour(); },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                  Container(
                    height: 250.h,
                    width: 350.w,
                    decoration: BoxDecoration(
                        gradient:LinearGradient(colors: [Couleur.primaryBlue,Couleur.secondaryGreen],begin: Alignment.topLeft,end: Alignment.bottomRight) ,//couleur.primaryPurple
                        borderRadius: BorderRadius.circular(12.r)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r)
                              ),
                              child:ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: widget.listsession.type_participant=="Organisateur" ?
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "QRCode de la tontine",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    QrImageView(
                                      backgroundColor: Colors.white,
                                      data: "tontine_plus/${widget.listsession.code_tontine}",
                                      size: 150.w,
                                    )
                                  ],
                                ):Column(
                                  children: [
                                    Text(
                                    "QRCode réservé à l’organisateur",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                  ),SizedBox(height: 10.h),
                                    ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 6.0.w, sigmaY: 6.0.h),
                                      child: QrImageView(
                                        backgroundColor: Colors.white,
                                        data: "Accès refusé",
                                        size: 150.w,
                                      ),
                                    ),
          
          
                                  ],
                                ),
                              ),
                            )
                        ]
                    ),
                  ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(widget.listsession.type_participant=="Organisateur")
                        TextButton.icon(onPressed: (){
                          envoyerRappelCotisation();
                        },style: TextButton.styleFrom(
                          backgroundColor: Couleur.accentOrange
                        ), label: Text("Envoyer rappel de cotisation",style: TextStyle(
                          fontSize: 14.sp,color: Colors.white
                        ),),icon: Icon(Icons.notification_add,color: Colors.white,),),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              offset: Offset(0, 1)
                          ),],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0.w),
                          child: Column(
                            mainAxisSize:MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Couleur.lightGray
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Icon(Icons.group_outlined,size: 30.r,color: Couleur.primaryBlue,),
                                  ),
                                ),
                              ),
                              Text("Total membres",style: TextStyle(
                                  color: Colors.grey[500]
                              ),),
                              Text("10/10",style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                              ),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              offset: Offset(0, 1)
                          ),],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0.w),
                          child: Column(
                            mainAxisSize:MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Couleur.lightGray
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Icon(Icons.calendar_today,size: 30.r,color: Couleur.primaryBlue,),
                                  ),
                                ),
                              ),
                              Text("Tour actuel",style: TextStyle(
                                color: Colors.grey[500],
                              ),),
                              Text("3/10",style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),)
                            ],
                          ),
                        ),
                      ),
                    ),SizedBox(width: 20.w,),Expanded(
                      child: Container(
          
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1,
                            offset: Offset(0, 1)
                          ),],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0.w),
                          child: Column(
                            mainAxisSize:MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Couleur.lightGray
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Icon(Icons.trending_up,size: 30.r,color: Couleur.primaryBlue,),
                                  ),
                                ),
                              ),
                              Text("Cagnotte",style: TextStyle(
                                color: Colors.grey[500],
                              ),),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                  child: Text("100000 FCFA",style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                  ),))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),),
                SizedBox(
                  height: 14.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          child: Card(
                            color: Colors.white,//couleur.primaryPurple,
                            child: Padding(
                              padding: EdgeInsets.all(10.0.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Couleur.accentOrange,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border(
                                        top: BorderSide(color: Couleur.accentOrange,width: 2,style: BorderStyle.solid),
                                        bottom: BorderSide(color: Couleur.accentOrange,width: 2,style: BorderStyle.solid),
                                        left: BorderSide(color: Couleur.accentOrange,width: 2,style: BorderStyle.solid),
                                        right: BorderSide(color: Couleur.accentOrange,width: 2,style: BorderStyle.solid),
                                      )
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(18.0.w),
                                      child: Icon(Icons.workspace_premium,size: 25.r,color: Colors.white,),
                                    ),),
                                  SizedBox(width: 14.w,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Prochain(e) bénéficiaire",style: TextStyle(
                                            fontSize: 15.sp,
                                          color: Couleur.accentOrange
                                        ),),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Text("${prenomsBeneficiare?? "N/A"} ${nomBeneficiare?? "N/A"} ",style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Couleur.accentOrange
                                        ),),
                                        Text(datePaiement,style: TextStyle(
                                            fontSize: 20.sp,
                                            color: Couleur.accentOrange
                                        ),),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            SizedBox(
            height: 14.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    child: Card(
                      color: Color(0xFFE3F2FD),//couleur.primaryPurple,
                      child: Padding(
                        padding: EdgeInsets.all(10.0.w),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Ma position",style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.grey[400]
                                          ),),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Text("Position #${prenomsBeneficiare?? "N/A"}",style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Couleur.primaryBlue
                                          ),),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Couleur.primaryBlue,
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(18.0.w),
                                          child: Icon(Icons.workspace_premium,size: 25.r,color: Colors.white,),
                                        ),),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Progression",style: TextStyle(
                                          fontSize: 14.sp,
                                        color: Colors.grey[400],
                                      ),),Text("3/10",style: TextStyle(
                                          fontSize: 20.sp,
                                          color: Colors.black,
                                        fontWeight: FontWeight.w500
                                      ),),
                                    ],
                                  ),
                                  SizedBox(height: 8.h,),
                                  LinearProgressIndicator(
                                    value: 3/10,
                                    backgroundColor: Colors.grey[500],
                                    minHeight: 6.h,
                                    borderRadius: BorderRadius.circular(12.r),
                                    valueColor: AlwaysStoppedAnimation<Color>(Couleur.primaryBlue),
                                  )
                                ],
                              ),
                            ),SizedBox(width: 14.w,),
          
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
                SizedBox(height: 10.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Row(
                    children: [
                      Text("Classement par points de confiance",style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold
                      ),)
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                  child: ListView.builder(
                    shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: membres.length,
                      itemBuilder: (context,index){
                        final Membre member=membres[index];
                        return GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: Center(
                                  child: Text("Détails membre",style: TextStyle(
                                    fontSize: 18.sp
                                  ),),
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Nom membre: ${member.nom_membre}",style: TextStyle(
                                        fontSize: 14.sp
                                    ),),
                                    SizedBox(
                                      height: 5.h,
                                    ),
          
                                        Text("Prénoms membre : ${member.prenom_membre}",style: TextStyle(
                                    fontSize: 14.sp
                                    ),),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text("Numéro membre : ${member.numero}",style: TextStyle(
                                            fontSize: 14.sp
                                        )
                                    ),SizedBox(
                                      height: 5.h,
                                    ),
                                        Text("Date d'intégration : ${member.date_participation.split(" ")[0]}",style: TextStyle(
                                            fontSize: 14.sp
                                        ),)
                                      ,SizedBox(
                                      height: 5.h,
                                    ),
          
                                        Text("Type: ${member.type}",style: TextStyle(
                                            fontSize: 14.sp
                                        ),)
                                      ,
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        contacterParticipant(member.numero);
                                      },
                                      child: InkWell(child: Row(
                                        children: [
                                          Image.asset("assets/whatsapp.png",width: 15.w,height: 15.h,),
                                          SizedBox(width: 5.w,),
                                          Text("Contacter ce participant")
                                        ],
                                      ),),
                                    )
                                  ],
                                ),
                                actions: [
                                  Center(
                                    child: TextButton.icon(onPressed: (){
                                      Navigator.of(context).pop();
                                    },style: TextButton.styleFrom(
                                        backgroundColor: Couleur.secondaryGreen
                                    ), label: Text("Compris",style: TextStyle(
                                      color: Colors.white,
                                        fontSize: 14.sp
                                    ),),icon: Icon(Icons.verified,color: Colors.white,),)
                                    ,
                                  )
                                ],
                              );
                            });
                          },
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(widget.listsession.numero_participant==member.numero?"Vous":member.nom_membre+" "+member.prenom_membre,style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold
                                ),),
                                AbsorbPointer(
                                  absorbing:widget.listsession.type_participant=="Organisateur" ? false:true,
                                  child: ElevatedButton(onPressed: (){
                                    print("Notifications personnalisé");
                                  },
                                  style: TextButton.styleFrom(
                                    elevation: 1,
                                    backgroundColor: Couleur.accentOrange
                                  ), child: Text("${member.points_confiance} Pts" ,style: TextStyle(
                                    color: Colors.white,
                                      fontSize: 12.sp
                                  ),),),
                                )
                              ],
                            ),
                            subtitle: Text("Type: ${member.type}",style: TextStyle(
                              fontSize: 14.sp
                            ),),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
