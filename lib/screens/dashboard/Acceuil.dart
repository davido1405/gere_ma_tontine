import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/screens/cotisations/payer_cotisation.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/penalites/payer_penalite.dart';
import 'package:gerematontine/screens/tontine/tour_tontine.dart';
import 'package:gerematontine/screens/tontine/wallet_tontine.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class acceuil extends StatefulWidget {
  final Session listsession;
  const acceuil({super.key, required this.listsession});

  @override
  State<acceuil> createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {
  
  Future<void> monTour() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=participants&action=mon_tour");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "code_tontine":widget.listsession.code_tontine
        }));

    if(reponse.statusCode==200){
      final tour=jsonDecode(reponse.body) as Map<String,dynamic>;
      if(tour['success']){
        Map<String,dynamic>donnee=tour['data'];
        if(donnee!=null){
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
          if(double.parse(montantPenalite)>5000.00){
            _critique=true;
          }
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
           tontine=Tontine.fromJson(data['data']);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalCotisation();
    totalPenalite();
    tontineInfo();
    totalPenalite();
    monTour();
  }
  String montantCotiser="0";

  String montantPenalite="0";

  bool _critique=false;

  Tontine? tontine;

  String numeroTour="N/A";

  int statut=0;

  @override
  build(BuildContext context) {
    if (tontine==null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 145,right: 10),
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
          padding: const EdgeInsets.only(left: 0.0,right: 5.0),
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
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>tourTontine(listsession: widget.listsession,  monTour: numeroTour, statut: statut,)));
                      },
                      child: Card(
                        color: couleur.primaryPurple,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mon numéro de tour",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(numeroTour,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                  Icon(statut==0?Icons.monetization_on_outlined:Icons.monetization_on,color: statut==0? Colors.red:Colors.green,size: 40,)
                                ],
                              ),
                              SizedBox(
                                height: 5,
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
                          padding: const EdgeInsets.all(15),
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
                              TweenAnimationBuilder(tween: Tween(begin: 0,end:double.parse(montantCotiser.toString())), duration: Duration(seconds: 2), builder: (context,value,child){
                                return Text("${value.toStringAsFixed(2)} FCFA",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),);
                              })
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
                                  TweenAnimationBuilder(tween: Tween(begin: 0,end: double.parse(montantPenalite)), duration: Duration(seconds: 2), builder: (context,value,child){
                                    return Text("${value.toStringAsFixed(2)} FCFA",
                                        style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),);
                                  })
                                ],
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Icon(_critique?Icons.warning:Icons.trending_down,color: _critique? Colors.red:Colors.white,size: 100,)
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
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ma tontine",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  TextButton.icon(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>walletTontine(tontine: tontine!,listsession: widget.listsession, numeroTour: int.parse(numeroTour), )));
                  }, label: Text("COFFRE",style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),icon: Icon(Icons.wallet,size: 30,),)
                ],
              )
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: Card(
              color: Color(0xFF3D0C94), // une nuance plus foncée du même violet,
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
                              Text(tontine!.code_tontine,style: TextStyle(
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
                                Text(tontine!.nom_tontine,style: TextStyle(
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
                                Text(tontine!.montant_cotisation+" FCFA",style: TextStyle(
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
                                Text(tontine!.nombre_participant.toString(),style: TextStyle(
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
                                Text(tontine!.frequence,style: TextStyle(
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
                                Text(tontine!.type,style: TextStyle(
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
                                Text(tontine!.date_creation,style: TextStyle(
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
            )
            )
          ],
        )
      ],
    )
    );
  }
}
