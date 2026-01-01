import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/participant/retirer_gains.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';
import '../../models/cotisation.dart';

class wallet_participant extends StatefulWidget {
  final Session listsession;
  const wallet_participant({super.key, required this.listsession});

  @override
  State<wallet_participant> createState() => _wallet_participantState();
}

class _wallet_participantState extends State<wallet_participant> {

  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;
  bool enCourtraitement=false;
  String lottieAffiche='';
  List<Cotisation>_listCotisation=[];
  String filtre="Toutes";



  final ScreenshotController _screenshotController=ScreenshotController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon wallet'),
      ),
      body: SafeArea(child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(12.w),child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: LinearGradient(colors: [Couleur.primaryBlue,Couleur.secondaryGreen],begin: Alignment.topLeft,end: Alignment.bottomRight),
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
                    SizedBox(height: 5.h,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[300],
                                borderRadius: BorderRadius.circular(12.r)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.0.w),
                                child: Icon(Icons.account_balance_outlined,size: 30.r,color: Colors.white,),
                              ),),
                            SizedBox(width: 10.w,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Solde personnel",style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                                ),),
                                Text("125 000 FCFA",style: TextStyle(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 15.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Expanded(child: TextButton.icon(onPressed: (){
                          }, label: Text("Recharger",style: TextStyle(color: Colors.white),),icon: Icon(Icons.save_alt_sharp,color: Colors.white,),style: TextButton.styleFrom(
                              backgroundColor: Couleur.accentOrange
                          ),)),
                          SizedBox(width: 15.w,),
                          Expanded(child: TextButton.icon(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>retirer_gains(listsession: widget.listsession,)));
                          }, label: Text("Retirer",style: TextStyle(color: Colors.white),),icon: Icon(Icons.north_east,color: Colors.white,),style: TextButton.styleFrom(
                              backgroundColor: Couleur.primaryBlue
                          ),))
                        ],)
                      ],
                    ),
                  ],
                ),
              ),
            ),),
            Padding(padding: EdgeInsets.all(12.w),child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
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
                    Row(children: [
                      Icon(Icons.shield_outlined,color: Couleur.primaryBlue,size: 30.r,),
                      Text("Limites KYC",style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                      ),)
                    ],),
                    SizedBox(height: 15.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Transaction journalière",style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400]
                        ),),
                        Text("75000 / 500000",style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),)
                      ],
                    ),
                    LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 10.h,
                      backgroundColor: Colors.blueGrey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(Couleur.primaryBlue),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    SizedBox(height: 15.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Volume mensuel",style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400]
                        ),),
                        Text("1750000 / 5000000",style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),)
                      ],
                    ),
                    LinearProgressIndicator(
                      value: 0.5,//A modifier(dynamiser)
                      minHeight: 10.h,
                      backgroundColor: Colors.blueGrey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(Couleur.secondaryGreen),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    TextButton.icon(onPressed: (){}, label: Text("Augmenter mes limites",style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Couleur.primaryBlue
                    ),),icon: Icon(Icons.arrow_forward_sharp,color: Couleur.primaryBlue,size: 20.r,),iconAlignment: IconAlignment.end,)
                  ],
                ),
              ),
            ),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:(){
                        setState(() {
                          filtre="Toutes";
                        });
                    },
                    child: Container(
                      decoration:BoxDecoration(
                          color: filtre=="Toutes"?Couleur.primaryBlue:Couleur.lightGray,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                        child: Text("Toutes",style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          color: filtre=="Toutes"?Colors.white:Colors.grey[400]
                        ),),
                      ),),
                  ),
                  SizedBox(width: 25.w,),
                  GestureDetector(
                    onTap:(){
                      setState(() {
                        filtre="Entrées";
                      });
                    },
                    child: Container(
                      decoration:BoxDecoration(
                          color: filtre=="Entrées"?Couleur.secondaryGreen:Couleur.lightGray,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                        child: Text("Entrées",style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color:filtre=="Entrées"?Colors.white:Colors.grey[400]
                        ),),
                      ),),
                  ),
                  SizedBox(width: 25.w,),
                  GestureDetector(
                    onTap:(){
                      setState(() {
                        filtre="Sorties";
                      });
                    },
                    child: Container(
                      decoration:BoxDecoration(
                          color:filtre=="Sorties"?Colors.red:Couleur.lightGray,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                        child: Text("Sorties",style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color:filtre=="Sorties"?Colors.white:Colors.grey[400]
                        ),),
                      ),),
                  ),
                ],),
            ),
            SizedBox(height: 25.h,),
            Padding(
              padding: EdgeInsets.only(right: 125.w,left: 15.w),
              child: Text("Historique des transactions",style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(
              height: 400.h,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: _listCotisation.isEmpty ?
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorFiltered(colorFilter: ColorFilter.mode(Couleur.primaryBlue, BlendMode.srcATop),
                              child: Lottie.asset("assets/animations/lottieflow-ecommerce-14-7-000000-easey.json",width: 150.w,height: 150.h),),
                            SizedBox(height: 15.h,),
                            Text("Aucune transaction disponible pour le moment")
                          ],
                        ),
                      ): ListView.builder(
                          itemCount: _listCotisation.length,
                          itemBuilder: (context,index){
                            final Cotisation cotisa=_listCotisation[index];
                            return GestureDetector(
                              onTap: (){
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true, // Add this to allow custom height
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setModalState) {
                                        return DraggableScrollableSheet(
                                          initialChildSize: 0.70, // 90% of screen height
                                          minChildSize: 0.5,
                                          //maxChildSize: 0.95,
                                          expand: false,
                                          builder: (context, scrollController) {
                                            return Column(
                                              children: [
                                                // Scrollable content
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    controller: scrollController,
                                                    child: Screenshot(
                                                      controller: _screenshotController,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Couleur.lightGray,
                                                          borderRadius: BorderRadius.circular(12.r),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0.w),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Center(
                                                                child: Image.asset(
                                                                  "assets/Djarra Finances V1.png",
                                                                  width: 80.w,
                                                                  height: 80.h,
                                                                ),
                                                              ),
                                                              SizedBox(height: 10.h),
                                                              Center(
                                                                child: Text(
                                                                  "Reçu de Transaction",
                                                                  style: TextStyle(
                                                                      fontSize: 20.sp,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.all(6.0.w),
                                                                child: Text("Aperçu"),
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(12.r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(6.0.w),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Type",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: FittedBox(
                                                                              fit: BoxFit.scaleDown,
                                                                              child: Text(
                                                                                cotisa.type_cotisation,
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Code",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              cotisa.code_cotisation,
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Opérateur ",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              cotisa.mode_paiement,
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Participant ",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              "${widget.listsession.nom_participant} ${widget.listsession.prenoms_participant}",
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Montant ",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              "${cotisa.montant} FCFA",
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Nombre de tour avancé ",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              cotisa.tour_avance=="null"?"0":cotisa.tour_avance,
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 5.h),
                                                              Padding(
                                                                padding: EdgeInsets.all(6.0.w),
                                                                child: Text("Détails"),
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(12.r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(6.0.w),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Statut",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: FittedBox(
                                                                              fit: BoxFit.scaleDown,
                                                                              child: Text(cotisa.statut_paiement),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Frais",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              "${(double.tryParse(cotisa.montant) ?? 0) * 1.02 - (double.tryParse(cotisa.montant) ?? 0)} FCFA",
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 3,
                                                                            child: Text(
                                                                              "Date et heure ",
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex: 2,
                                                                            child: Text(
                                                                              cotisa.date_paiement,
                                                                              style: TextStyle(fontSize: 15.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 50.h,),
                                                              Center(child: Text("En partenariat avec EcoBank")),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Fixed button at bottom
                                                Padding(
                                                  padding: EdgeInsets.all(8.0.w),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: TextButton.icon(
                                                      onPressed: () async {
                                                        final Uint8List? image = (await _screenshotController.capture());
                                                        if (image != null) {
                                                          final directory = await getApplicationDocumentsDirectory();
                                                          final file = File('${directory.path}/recu_${widget.listsession.nom_participant}_${cotisa.date_paiement}.png');
                                                          await file.writeAsBytes(image);
                                                          await Share.shareXFiles([XFile(file.path)], text: 'Réçu du paiement');
                                                        }
                                                      },
                                                      label: Text(
                                                        "Partager le reçu",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      icon: Icon(Icons.ios_share_rounded, color: Colors.white),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Couleur.secondaryGreen,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(cotisa.code_cotisation,style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    Text(cotisa.date_paiement.split(" ")[0],style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold
                                    ),)
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Montant: ${cotisa.montant} FCFA",style: TextStyle(
                                        fontSize: 14.sp
                                    ),),
                                    Text(cotisa.statut_paiement,style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14.sp
                                    ),),
                                  ],

                                ),
                              ),
                            );
                          })
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
