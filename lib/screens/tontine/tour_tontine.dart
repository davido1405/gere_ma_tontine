import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/beneficiare.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';

class tourTontine extends StatefulWidget {
  final Session listsession;
  final String monTour;
  final int statut;
  const tourTontine({super.key, required this.listsession, required this.monTour,required this.statut});

  @override
  State<tourTontine> createState() => _tourTontineState();
}

class _tourTontineState extends State<tourTontine> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifierTour();
    listeBeneficiare();
    Timer.periodic(Duration(seconds: 2),(timer){
      verifierTour();
      listeBeneficiare();
    });
  }

  List<Beneficiare> _listOrdre=[];

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
            positionBeneficiare=tour['ordre'];
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
  late int positionBeneficiare=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Planning des tours",style: TextStyle(
            fontSize: 20.sp
          ),),
        ),
      ),
      body: SafeArea(child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          children: [
            ClipRRect(
              child: Card(
                color: Couleur.primaryBlue,//couleur.primaryPurple,
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
                                Text("Bénéficiaire du tour",style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),),
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nom: ${nomBeneficiare?? "N/A"}",style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.white
                                      ),),
                                      SizedBox(
                                        width: 10.h,
                                      ),
                                      Text("Prénoms: ${prenomsBeneficiare?? "N/A"}",style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.white
                                      ),),
                                      Text("Position: ${positionBeneficiare.toString() ?? "N/A"}",style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.white
                                      ),),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(child: ColorFiltered(colorFilter: ColorFilter.mode(Couleur.accentOrange, BlendMode.srcATop),
                          child: Lottie.asset("assets/animations/lottieflow-ecommerce-14-13-000000-easey.json",width: 140.w,height: 140.h)),)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 10.h,
            ),
            SizedBox(
              height: 5.h,
            ),
            Text("Prochains bénéficiare",style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp
            ),),
            SizedBox(
              height: 5.h,
            ),
            SizedBox(
              height: 500.h,
              width: double.maxFinite.w,
              child: _listOrdre.isEmpty ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Lottie.asset("assets/animations/No-Data.json",width: 150.w,height: 150.h),
                  SizedBox(height: 15.h,),
                  Center(child: Text("Les tours seront générés automatiquement dès que possible. Merci",overflow: TextOverflow.ellipsis,maxLines: 2,))
                ]
              )): ListView.builder(
                itemCount: _listOrdre.length,
                itemBuilder: (context, index) {
                  final Beneficiare prochain = _listOrdre[index];
                  return ListTile(
                    title: Text(widget.listsession.code_participant==prochain.codeBeneficiare?"Vous":
                      "${prochain.prenomsBeneficiare} ${prochain.nomBeneficiare}",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("Position: ${prochain.positionBeneficiare}",
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),),Text("Date prévu: ${prochain.dateTour.split(" ")[0]}",
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),)],),
                    trailing: Icon(
                      prochain.statutBeneficiare == 0
                          ? Icons.timelapse
                          : Icons.payments_rounded ,color: prochain.statutBeneficiare==0? Colors.black:Colors.green,
                    ),
                  );
                },
              ),
            )

        ],
        ),
      ))
    );
  }
}
