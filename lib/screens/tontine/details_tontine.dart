import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/membres.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart' as http;

import '../../constants/colors.dart';
import '../../constants/server.dart';

class details_tontine extends StatefulWidget {
  final Session listsession;
  const details_tontine({super.key, required this.listsession});

  @override
  State<details_tontine> createState() => _details_tontineState();
}

class _details_tontineState extends State<details_tontine> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargerMembres();
  }

  late List<Membre>membres=[];

  Future<void>chargerMembres()async{
    final url=Uri.parse("${adress}?ressource=tontines&action=lister_membres");
    final reponse=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
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
    final url=Uri.parse("${adress}?ressource=notifications&action=envoyer_rappel_cotisation");
    final reponse=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
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
                }, label: Text("Ok"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
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
              }, label: Text("Ok"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
            )
          ],
        );
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Détails tontine",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold),),),
      ),
      body: SafeArea(
        child: Column(
          children: [
              Center(child: Container(
                height: 230.h,
                width: 350.w,
                decoration: BoxDecoration(
                    color: Color( 0xFF2596be),//couleur.primaryPurple
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(widget.listsession.type_participant=="Organisateur")
                        Container(
                          height: 180.h,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Image.asset("assets/qrCode.png"),
                        ),
                      if(widget.listsession.type_participant!="Organisateur")
                        Container(
                          height: 225.h,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 5.0.w, sigmaY: 5.0.h),
                                child: Image.asset("assets/qrCode.png", height: 130),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                "QR réservé à l’organisateur",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),),
                    ]
                ),
              ),
              ),
            SizedBox(
              height: 5.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 25.w,right: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(widget.listsession.type_participant=="Organisateur")
                    TextButton(onPressed: (){
                      envoyerRappelCotisation();
                    },style: TextButton.styleFrom(
                      backgroundColor: couleur.lightGray
                    ), child: Text("Envoyer rappel de cotisation",style: TextStyle(
                      fontSize: 14.sp,
                    ),),),
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Row(
                children: [
                  Text("Liste des participants à cette tontine",style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
              height: 370.h,
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
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
                                    content: SizedBox(
                                      height: 145,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text("Nom membre: ${member.nom_membre}",style: TextStyle(
                                                  fontSize: 14.sp
                                              ),)
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Text("Prénoms membre : ${member.prenom_membre}",style: TextStyle(
                                          fontSize: 14.sp
                                          ),)
                                            ],
                                          ),SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Text("Email membre : ${member.email}",style: TextStyle(
                                              fontSize: 14.sp
                                              ),)
                                            ],
                                          ),SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Text("Numéro membre : ${member.numero}",style: TextStyle(
                                                  fontSize: 14.sp
                                              ),)
                                            ],
                                          ),SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Text("Date d'intégration : ${member.date_participation}",style: TextStyle(
                                                  fontSize: 14.sp
                                              ),)
                                            ],
                                          ),SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Text("Type: ${member.type}",style: TextStyle(
                                                  fontSize: 14.sp
                                              ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Center(
                                        child: TextButton.icon(onPressed: (){
                                          Navigator.of(context).pop();
                                        }, label: Text("OK",style: TextStyle(
                                            fontSize: 14.sp
                                        ),),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
                                        ,
                                      )
                                    ],
                                  );
                                });
                              },
                              child: ListTile(
                                title: Text(widget.listsession.email_participant==member.email?"Vous":member.nom_membre+" "+member.prenom_membre,style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold
                                ),),
                                subtitle: Text("Type: "+member.type,style: TextStyle(
                                  fontSize: 14.sp
                                ),),
                              ),
                            );
                          })
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
