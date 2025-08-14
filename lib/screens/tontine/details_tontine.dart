import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gerematontine/models/membres.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart' as http;

import '../../constants/colors.dart';

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
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=lister_membres");
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
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=notifications&action=envoyer_rappel_cotisation");
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
        title: Center(child: Text("Détails tontine",style: TextStyle(fontWeight: FontWeight.bold),),),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
            Center(child: Container(
              height: 200,
              width: 350,
              decoration: BoxDecoration(
                  color: couleur.primaryPurple,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(widget.listsession.type_participant=="Organisateur")
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Image.asset("assets/qrCode.png"),
                      ),
                    if(widget.listsession.type_participant!="Organisateur")
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Image.asset("assets/qrCode.png", height: 150),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "QR réservé à l’organisateur",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25,right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(widget.listsession.type_participant=="Organisateur")
                  TextButton(onPressed: (){
                    envoyerRappelCotisation();
                  }, child: Text("Envoyer rappel de cotisation"),style: TextButton.styleFrom(
                    backgroundColor: couleur.lightGray
                  ),),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text("Liste des participants à cette tontine",style: TextStyle(
                  fontWeight: FontWeight.bold
                ),)
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 410,
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
                                    child: Text("Détails membre"),
                                  ),
                                  content: Container(
                                    height: 145,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text("Nom membre: ${member.nom_membre}")
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text("Prénoms membre : ${member.prenom_membre}")
                                          ],
                                        ),SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text("Email membre : ${member.email}")
                                          ],
                                        ),SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text("Numéro membre : ${member.numero}")
                                          ],
                                        ),SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text("Date d'intégration : ${member.date_participation}")
                                          ],
                                        ),SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text("Type: ${member.type}")
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: TextButton.icon(onPressed: (){
                                        Navigator.of(context).pop();
                                      }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
                                      ,
                                    )
                                  ],
                                );
                              });
                            },
                            child: ListTile(
                              title: Text(widget.listsession.email_participant==member.email?"Vous":member.nom_membre+" "+member.prenom_membre,style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                              subtitle: Text("Type: "+member.type),
                            ),
                          );
                        })
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}
