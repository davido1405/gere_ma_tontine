import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/membres.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';

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

  late AnimationController _controllerLotti;

  late List<Membre>membres=[];

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
    final reponse=await http.post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
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
            content: SizedBox(
              height: 200.h,
              child: Column(children: [
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
            ),
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
              backgroundColor: Couleur.primaryBlue
              ), label: Text("Ok"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
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
        automaticallyImplyLeading: false,
        title: Center(child: Text("Détails tontine",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold),),),
      ),
      body: SafeArea(
        child: Column(
          children: [
              Center(child: Container(
                height: 250.h,
                width: 400.w,
                decoration: BoxDecoration(
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r)
                          ),
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: widget.listsession.type_participant=="Organisateur" ?
                            QrImageView(
                              backgroundColor: Colors.white,
                              data: "tontine_plus/${widget.listsession.code_tontine}",
                              size: 200.w,
                            ):Column(
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 6.0.w, sigmaY: 6.0.h),
                                  child: QrImageView(
                                    backgroundColor: Colors.white,
                                    data: "Accès refusé",
                                    size: 200.w,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "QRCode réservé à l’organisateur",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                    ]
                ),
              ),
              ),
            SizedBox(
              height: 15.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(widget.listsession.type_participant=="Organisateur")
                    TextButton.icon(onPressed: (){
                      envoyerRappelCotisation();
                    },style: TextButton.styleFrom(
                      backgroundColor: Couleur.secondaryGreen
                    ), label: Text("Envoyer rappel de cotisation",style: TextStyle(
                      fontSize: 14.sp,color: Colors.white
                    ),),icon: Icon(Icons.notification_add,color: Colors.white,),),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Row(
                children: [
                  Text("Classement par points de confiance",style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            SizedBox(
              height: 350.h,
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
                                      height: 160.h,
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
