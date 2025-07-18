import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/screens/cotisations/payer_cotisation.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/penalites/payer_penalite.dart';
import 'package:gerematontine/screens/tontine/details_tontine.dart';
import 'package:http/http.dart';

class acceuil extends StatefulWidget {
  final Session listsession;
  const acceuil({super.key, required this.listsession});

  @override
  State<acceuil> createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {

  Future <void> totalCotisation() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=cotisations&action=total_cotisation");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    })).timeout(Duration(seconds: 30));

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

  Future <void> totalPenalite() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=cotisations&action=total_penalite");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    })).timeout(Duration(seconds: 30));

    if(reponse.statusCode==200){
      final total=jsonDecode(reponse.body) as Map<String,dynamic>;
      bool success=total['success'];
      if(success==true){
        setState(() {
          montantPenalite=total['data'].toString();
        });
      }
    }
  }

  Future<void> tontineInfo() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=details_tontine");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode({
      "code_tontine":widget.listsession.code_tontine
    })).timeout(Duration(seconds: 50));
    if(reponse.statusCode==200){
      final data=jsonDecode(reponse.body) as Map<String,dynamic>;
      if(data['success']==true){
        setState(() {
           _tontine=Tontine.fromJson(data['data']);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalCotisation();
    tontineInfo();
    totalPenalite();
  }
  String montantCotiser="0 FCFA";

  String montantPenalite="0 FCFA";

  Tontine? _tontine;


  @override
  build(BuildContext context) {
    return SafeArea(child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 150,right: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text("Acceuil",style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Container(
                  child: Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>parametre(listsession: widget.listsession,)));
                      }, icon: Icon(Icons.settings_outlined),color: Colors.black,
                      ),
                      IconButton(onPressed: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>connexion_screen()), (route)=>false);
                      }, icon: Icon(Icons.logout,color: Colors.black,))
                    ],
                  ),
                )
              ]
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10.0),
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text("Bienvenu, ${widget.listsession.nom_participant} ${widget.listsession.prenoms_participant}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),)
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>details_tontine(listsession: widget.listsession,)));
                      },
                      child: Card(
                        color: couleur.primaryPurple,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Numéro de tour",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("3",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    ),
                    Expanded(child: GestureDetector(
                      onTap: (){
                        setState(() {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>payer_cotisation(listsession: widget.listsession,)));
                        });
                      },
                      child: Card(
                        color: couleur.primaryPurple,
                        margin: EdgeInsets.all(5),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              Text("des cotisations",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(montantCotiser+" FCFA",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>payer_penalite(listsession: widget.listsession,)));
                      },
                      child: Card(
                        color: couleur.primaryPurple,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Montant",style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                  ),
                                  Text("total des pénalités",style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(montantPenalite+" FCFA",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Icon(Icons.trending_down,color: Colors.white,size: 100,)
                            ],
                          ),
                        ),
                      ),
                    )
                    )
                  ],
                )
              ],
            )
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ma tontine",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>details_tontine(listsession: widget.listsession)));
              },
              child: Card(
                color: Colors.cyan[500],
                margin: EdgeInsets.all(10),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Code tontine: ",style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white
                                ),),
                                Text(_tontine!.code_tontine,style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),)
                              ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Nom tontine: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.nom_tontine,style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Montant cotisation: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.montant_cotisation+" FCFA",style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                children: [
                                  Text("Nombre participant: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.nombre_participant.toString(),style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Fréquence cotisation: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.frequence,style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Type de tirage: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.type,style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date de création: ",style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),),
                                  Text(_tontine!.date_creation,style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)
                                ]
                            ),

                          ],
                        ),
                      ],
                    )
                ),
              ),
            )
            )
          ],
        )
      ],
    )
    );
  }
}
