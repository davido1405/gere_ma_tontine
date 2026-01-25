import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/cotisation.dart';
import 'package:gerematontine/models/preview.dart';
import 'package:gerematontine/models/session.dart';
import 'package:flutter/material.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/colors.dart';
import '../../constants/server.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/infos_wallet_participant.dart'; // Pour getApplicationDocumentsDirectory()


class payer_cotisation extends StatefulWidget {
  final Session listsession;
  const payer_cotisation( {super.key, required this.listsession});

  @override
  State<payer_cotisation> createState() => _payer_cotisationState();
}

class _payer_cotisationState extends State<payer_cotisation> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCotisation();
    _selectedOption="Wallet Participant";
    payable=false;
    infosFinanceParticipant();
  }



  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;
  bool enCourtraitement=false;
  String lottieAffiche='';
  String modePaiement="Choisir mode de paiement";
  bool wallet_parti=true;
  bool payable=false;
  int? cotisationManque;
  String? montantAffiche;
  int? fraisTransac;
  int? totalTransac;

  PreviewCotisation? previewCotisation;

  InfosWallet? infos_wallet_participant;


  List<Cotisation>_listCotisation=[];

  String _selectedOption ="";

  TextEditingController montant=TextEditingController();
  TextEditingController montantFraisinculs=TextEditingController();
  final ScreenshotController _screenshotController=ScreenshotController();

  //late bool paye;

  Future<void>fetchCotisation() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=cotisations&action=voir_mes_cotisations");
    final response = await http.post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: convert.jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    }));
    if(response.statusCode==200){
      final Map <String,dynamic> data =convert.jsonDecode(response.body);
      List<dynamic>coti=data['data']??[];
      setState(() {
        _listCotisation=coti.map((coti)=>Cotisation.fromJson(coti)).toList();
      });
    }
  }

  Future<void>preview()async{
    String? jwt = await widget.listsession.getSecureJwt();
    // 1️⃣ Affiche le dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false, // empêche de fermer en cliquant dehors
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Statut")),
          content: SizedBox(
            height: 200.h,
            child: Center(
              child: Column(
                children: [
                  Lottie.asset("assets/animations/Card swiping.json", width: 150.w, height: 150.h),
                  const SizedBox(height: 10),
                  const Text("Chargement de l'aperçu...")
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final url = Uri.parse("${adress}?ressource=cotisations&action=preview_cotisation");
      final reponse = await http.post(
        url,
        headers: {
          "content-Type": "application/json",
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode({
          "code_tontine": widget.listsession.code_tontine,
          "code_participant": widget.listsession.code_participant,
          "montant": int.tryParse(montant.text) ?? 0,
        }),
      );

      // 2️⃣ Fermer le dialogue de chargement une fois la réponse obtenue
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (reponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(reponse.body);
        bool success = data['success'];

        if(success){
          if(mounted){
            setState(() {
              previewCotisation=PreviewCotisation.fromJson(data['data']);
            });
          }
        }
      } else {
        setState(() => enCourtraitement = false);
        print("Erreur serveur : ${reponse.statusCode}");
      }
    } catch (e) {
      // ✅ Vérifier mounted AVANT d'utiliser context
      if (!mounted) return;

      // Fermer le dialogue
      if (Navigator.canPop(context)) {
        setState(() => enCourtraitement = false);
        Navigator.pop(context);
      }


      // 3bis️⃣ Affiche un dialogue d’erreur
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erreur"),
          content: Text("Une erreur est survenue : $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),style: TextButton.styleFrom(
                backgroundColor: Couleur.secondaryGreen
            ),
              child: const Text("Compris",style: TextStyle(
                  color: Colors.white
              ),),
            )
          ],
        ),
      );
    }
  }

  Future<void> payerCotisation(String x, String y) async {
    String? jwt = await widget.listsession.getSecureJwt();
    setState(() {
      enCourtraitement = true;
    });

    // 1️⃣ Affiche le dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false, // empêche de fermer en cliquant dehors
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Statut")),
          content: SizedBox(
            height: 200.h,
            child: Center(
              child: Column(
                children: [
                  Lottie.asset("assets/animations/Card swiping.json", width: 150.w, height: 150.h),
                  const SizedBox(height: 10),
                  const Text("Paiement en cours...")
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final url = Uri.parse("${adress}?ressource=cotisations&action=payer_cotisation");
      final reponse = await http.post(
        url,
        headers: {
          "content-Type": "application/json",
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode({
          "code_tontine": widget.listsession.code_tontine,
          "code_participant": widget.listsession.code_participant,
          "montant": int.tryParse(x) ?? 0,
          "libelle_mode_paiement": y
        }),
      );

      // 2️⃣ Fermer le dialogue de chargement une fois la réponse obtenue
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (reponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(reponse.body);
        bool success = data['success'];

        // 3️⃣ Affiche le résultat (succès ou erreur)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Statut paiement",
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  success
                      ? Lottie.asset(
                    'assets/animations/Approve.json',
                    width: 150.w,
                    height: 150.h,
                  )
                      : Lottie.asset(
                    'assets/animations/Sign for error _ Flat style.json',
                    width: 150.w,
                    height: 150.h,
                  ),
                  Text(
                    data['message'],
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        enCourtraitement = false;
                        _selectedOption = "";
                      });
                      Navigator.of(context).pop();
                      montant.clear();
                      montantFraisinculs.clear();
                      fetchCotisation();
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
          },
        );
      } else {
        setState(() => enCourtraitement = false);
        print("Erreur serveur : ${reponse.statusCode}");
      }
    } catch (e) {
      // 2bis️⃣ Fermer le dialogue de chargement si une erreur se produit
      Navigator.of(context).pop();
      setState(() => enCourtraitement = false);

      // 3bis️⃣ Affiche un dialogue d’erreur
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erreur"),
          content: Text("Une erreur est survenue : $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),style: TextButton.styleFrom(
              backgroundColor: Couleur.secondaryGreen
            ),
              child: const Text("Compris",style: TextStyle(
                color: Colors.white
              ),),
            )
          ],
        ),
      );
    }
  }

  Future<void>infosFinanceParticipant() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participants&action=infos_wallet_participant");
    final response = await http.post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: convert.jsonEncode({
      "code_participant":widget.listsession.code_participant
    }));
    if(response.statusCode==200){
      Map <String,dynamic> data =convert.jsonDecode(response.body);
      setState(() {
        infos_wallet_participant=InfosWallet.fromJson(data['data']);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Payer ma cotisation",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async{
            infosFinanceParticipant();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  Padding(padding: EdgeInsets.all(12.w),child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey,
                              width: 0.5.w,
                              style: BorderStyle.solid),
                          bottom: BorderSide(color: Colors.grey,
                              width: 0.5.w,
                              style: BorderStyle.solid),
                          left: BorderSide(color: Colors.grey,
                              width: 0.5.w,
                              style: BorderStyle.solid),
                          right: BorderSide(color: Colors.grey,
                              width: 0.5.w,
                              style: BorderStyle.solid),

                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                          )]
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.symmetric(horizontal:10.w,vertical: 5.h),child:
                            Text("Montant à cotiser",style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey
                            ),),),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0.w,),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: montant,
                              decoration: InputDecoration(
                                suffix: Text("FCFA"),
                                hint: Text("0 FCFA",style: TextStyle(
                                  fontSize: 25.sp,
                                    color: Colors.grey
                                ),)
                              ),
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: Colors.black
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        montant.setText("10000");
                                        print("repartition de ${montant.text}");
                                      },
                                      child: Container(
                                        decoration:BoxDecoration(
                                          color: Couleur.lightGray,
                                          borderRadius: BorderRadius.circular(12.r)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                          child: Text("10k",style: TextStyle(
                                            fontSize: 15.sp,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        ),),
                                    ),
                                    GestureDetector(
                                      onTap:(){
                                        montant.setText("15000");
                                        print("repartition de ${montant.text}");
                                      },
                                      child: Container(
                                        decoration:BoxDecoration(
                                            color: Couleur.lightGray,
                                            borderRadius: BorderRadius.circular(12.r)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                          child: Text("15k",style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        ),),
                                    ),
                                    GestureDetector(
                                      onTap:(){
                                        montant.setText("25000");
                                        print("repartition de ${montant.text}");
                                      },
                                      child: Container(
                                        decoration:BoxDecoration(
                                            color: Couleur.lightGray,
                                            borderRadius: BorderRadius.circular(12.r)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                          child: Text("25k",style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        ),),
                                    ),
                                    GestureDetector(
                                      onTap:(){
                                        montant.setText("50000");
                                        print("repartition de ${montant.text}");
                                      },
                                      child: Container(
                                        decoration:BoxDecoration(
                                            color: Couleur.lightGray,
                                            borderRadius: BorderRadius.circular(12.r)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                          child: Text("50k",style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        ),),
                                    ),
                                    ],),
                                SizedBox(height: 15.h,),
                                Row(children: [
                                  Expanded(child: TextButton.icon(onPressed: () async{
                                    if(mounted){
                                      setState(() {
                                        montantAffiche=montant.text;
                                      });
                                      preview();
                                    }

                                    print('Calculer la ventilation');
                                  }, label: Text("Repartir",style: TextStyle(color: Colors.white),),icon: Icon(Icons.currency_exchange_rounded,color: Colors.white,),style: TextButton.styleFrom(
                                    backgroundColor: Couleur.accentOrange
                                  ),))
                                ],)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),),
                  SizedBox(
                    height: 10.h,
                  ),
                Padding(padding: EdgeInsets.all(12.w),child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      bottom: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      left: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      right: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),

                    ),
                    borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                    )]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Text("Repartition de votre cotisation",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp
                          ),),
                        ),
                        SizedBox(height: 5.h,),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text("Montant"),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("${montantAffiche ?? "0"} FCFA",style: TextStyle(
                              fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),),
                            )
                          ],),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text("Cotisation(s) manquée(s)"),
                              Text("${previewCotisation?.cotisations_manquees ?? 0}",style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),),
                          ],),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Situation tour en cours"),
                              Container(
                                decoration: BoxDecoration(
                                    color: previewCotisation?.situtaion_tour.toString()=="Payable"?Couleur.secondaryGreen:Colors.red,
                                    borderRadius: BorderRadius.circular(18.r)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18.0.w,vertical: 5.h),
                                  child: Text(previewCotisation?.situtaion_tour ?? "En attente",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),)
                            ],),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Tours en avance"),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("${previewCotisation?.tour_avance ?? 0}"  ,style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),),
                              )
                            ],),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text("Total des frais"),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("${previewCotisation?.total_frais ?? 0} FCFA"  ,style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),),
                            )
                          ],),
                        ),
                        Divider(height: 10.h,thickness: 1.5.w,indent: 25.w,endIndent: 25.w,),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total transaction"),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("${previewCotisation?.total_transaction ?? 0} FCFA"  ,style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),),
                              )
                            ],),
                        ),

                      ],
                    ),
                  ),
                ),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                      child: Text("Mode paiement",style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600]
                      ),),
                    ),
                    SizedBox(height: 10.h,),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              wallet_parti=true;
                              _selectedOption="Wallet participant";
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(12.0.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                      child: Row(children: [
                                      Container(
                                      decoration:BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20.r)),
                                    child: Padding(padding: EdgeInsets.all(10.w),child: Icon(Icons.wallet_outlined,color: Couleur.primaryBlue,size: 50,),),),
                                    SizedBox(width: 10.w,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Mon wallet",style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w500
                                        ),),
                                        Text("Solde: ${infos_wallet_participant?.solde_participant ?? 0} FCFA",style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey
                                        ),)
                                        ],)
                                        ],
                                      )),
                                  ?wallet_parti
                                      ? Expanded(
                                      child: Icon(Icons.check_circle_outline_outlined,color: Couleur.primaryBlue,))
                                      :null
                                  ]
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -1.h,
                            left: 270.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Couleur.secondaryGreen,
                                borderRadius: BorderRadius.circular(15.r)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.0.w),
                                child: Text("Recommandé",style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),),
                              ),))
                      ]),
                    SizedBox(height: 10.h,),
                    GestureDetector(
                      onTap: (){
                        if(mounted){
                          setState(() {
                            wallet_parti=false;
                          });
                          showModalBottomSheet(
                              backgroundColor: Colors.grey[300],
                              elevation: 3,
                              isDismissible: true,
                              //transitionAnimationController: AnimationController(vsync: ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setModalState) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12.r)),
                                        height: 400.h,
                                        width: double.maxFinite.w,
                                        child: Column(
                                            children: [
                                              SizedBox(
                                                height: 15.h,
                                              ),
                                              Center(
                                                child: Text("Options Mobile Money",style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.w500
                                                ),),
                                              ),SizedBox(
                                                height: 5.h,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Card(
                                                        elevation: 0,
                                                        color: Couleur.lightGray,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                          child: InkWell(
                                                            splashColor: Colors.blueAccent.withOpacity(0.2),
                                                            highlightColor: Colors.transparent,
                                                            onTap: (){
                                                              setModalState(() {
                                                                _selectedOption="Wave";
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                    flex:3,
                                                                    child: Row(children: [
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius.circular(5.r),
                                                                        child: Image.asset("assets/wave.png",fit: BoxFit.cover,height: 50.h,
                                                                          width: 100.w,),
                                                                      ),
                                                                      SizedBox(width: 10.w,),
                                                                      Text("WAVE"),
                                                                    ],)),
                                                                SizedBox(width: 60.w,),
                                                                Expanded(
                                                                  flex:1,
                                                                  child: RadioListTile<String>(value: "Wave", groupValue: _selectedOption, onChanged: (value){
                                                                    setModalState(() {
                                                                      _selectedOption=value!;
                                                                      print(_selectedOption.toString());
                                                                    });
                                                                  }),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Card(
                                                        elevation: 0,
                                                        color: Couleur.lightGray,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                          child: InkWell(
                                                            splashColor: Colors.deepOrange.withOpacity(0.2),
                                                            highlightColor: Colors.transparent,
                                                            onTap: (){
                                                              setModalState(() {
                                                                _selectedOption="Orange Money";
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Expanded(
                                                                    flex:3,
                                                                    child: Row(children: [
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius.circular(5.r),
                                                                        child: Image.asset("assets/orange money 2.png",fit: BoxFit.cover,height: 50.h,
                                                                          width: 100.w,),
                                                                      ),
                                                                      SizedBox(width: 10.w,),
                                                                      Text("ORANGE"),
                                                                    ],)),
                                                                SizedBox(width: 70.w,),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: RadioListTile<String>(value: "Orange Money", groupValue: _selectedOption, onChanged: (value){
                                                                    setModalState(() {
                                                                      _selectedOption=value!;
                                                                      print(_selectedOption.toString());
                                                                    });
                                                                  }),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Card(
                                                        elevation: 0,
                                                        color: Couleur.lightGray,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                          child: InkWell(
                                                            splashColor: Colors.yellow.withOpacity(0.5),
                                                            highlightColor: Colors.transparent,
                                                            onTap: (){
                                                              setModalState(() {
                                                                _selectedOption="MTN Money";
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                    flex:3,
                                                                    child: Row(children: [
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius.circular(5.r),
                                                                        child: Image.asset("assets/MTN MONEY.png",fit: BoxFit.cover,height: 50.h,
                                                                          width: 100.w,),
                                                                      ),
                                                                      SizedBox(width: 10.w,),
                                                                      Text("MTN"),
                                                                    ],
                                                                    )
                                                                ),
                                                                SizedBox(width: 70.w,),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: RadioListTile<String>(value: "MTN Money", groupValue: _selectedOption, onChanged: (value){
                                                                    setModalState(() {
                                                                      _selectedOption=value!;
                                                                      print(_selectedOption.toString());
                                                                    });
                                                                  }),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Card(
                                                        elevation: 0,
                                                        color: Couleur.lightGray,
                                                        child: InkWell(
                                                          splashColor: Colors.blueAccent.withOpacity(0.5),
                                                          highlightColor: Colors.transparent,
                                                          onTap: (){
                                                            setModalState(() {
                                                              _selectedOption="Moov Money";
                                                            });
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                  flex:3,
                                                                  child: Row(children: [
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(14.r),
                                                                      child: Image.asset("assets/moov.png",fit: BoxFit.cover,height: 50.h,
                                                                        width: 110.w,),
                                                                    ),
                                                                    SizedBox(width: 10.w,),
                                                                    Text("MOOV"),
                                                                  ],)),
                                                              SizedBox(width: 70.w,),
                                                              Expanded(
                                                                flex: 1,
                                                                child: RadioListTile<String>(value: "Moov Money", groupValue: _selectedOption, onChanged: (value){
                                                                  setModalState(() {
                                                                    _selectedOption=value!;
                                                                    print(_selectedOption.toString());
                                                                  });
                                                                }),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 100.w),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: ElevatedButton.icon(onPressed: enCourtraitement? null: (){
                                                      String modePaie=_selectedOption.toString();
                                                      String temp=modePaie.toString();
                                                      Navigator.of(context).pop();
                                                      if(mounted){
                                                        setState(() {
                                                          modePaiement=temp;
                                                        });
                                                        print(modePaiement);
                                                      }
                                                    },style: TextButton.styleFrom(
                                                        backgroundColor: Couleur.secondaryGreen
                                                    ), label:Text("Continuer",style: TextStyle(
                                                      color: Colors.white
                                                    ),),icon:Icon(Icons.monetization_on,color: Colors.white,),))
                                                  ],
                                                ),
                                              )
                                            ]),
                                      );}
                                );
                              });
                        }
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.0.w),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Row(
                                children: [
                                  Container(
                                    decoration:BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Padding(padding: EdgeInsets.all(10.w),child: Icon(Icons.phone_android_rounded,color: Couleur.primaryBlue,size: 50,),),),
                                  SizedBox(width: 10.w,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Mobile Money",style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w500
                                      ),),
                                      Text("${modePaiement.toString()}",style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey
                                      ),)
                                    ],
                                  ),
                                ],
                              ),),
                              ?wallet_parti==false?
                              Expanded(
                                  child: Icon(Icons.check_circle_outline_outlined,color: Couleur.primaryBlue,))
                                  :null
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  SizedBox(
                  height: 10.h,
                ),
                  ElevatedButton.icon(onPressed: () async{
                    String montantCotiser=(previewCotisation?.total_transaction).toString();
                    String modePaiement=_selectedOption.toString();
                    if(montantCotiser.isEmpty || modePaiement.isEmpty){
                      DelightToastBar(
                        position: DelightSnackbarPosition.top,
                        autoDismiss: true,
                        snackbarDuration: Duration(seconds: 2),
                        builder: (BuildContext context) {
                          return ToastCard(
                            title: Row(
                              mainAxisAlignment:MainAxisAlignment.start,
                              children: [Icon(Icons.error_outline,color: Colors.white,size: 30.r,),Text("Veuillez remplir tout les champs !",style: TextStyle(
                                  color: Colors.white
                              ),)],),
                            color: Colors.red.shade700,);
                        },).show(context);
                    }else{
                      payerCotisation(montantCotiser,modePaiement);
                    }

                  }, label: Text("Confirmer le paiement",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),),icon: Icon(Icons.payments_rounded),style: ElevatedButton.styleFrom(
                backgroundColor: Couleur.secondaryGreen,
                iconColor: Colors.white,
                iconSize: 30.r
            )),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
