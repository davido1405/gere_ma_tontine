import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:http/http.dart' as http;

class creer_tontine extends StatefulWidget {
  final Session listsession;
  const creer_tontine({super.key, required this.listsession});

  @override
  State<creer_tontine> createState() => _creer_tontineState();
}

class _creer_tontineState extends State<creer_tontine> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    typeTontines();
    frequenceTontines();
  }
  
  List<String>typeTontine=[];

  List<String>frequenceCotisa=[];

  String? _typeChoisi;

  String? _frequenceChoisi;



  //Récupération des informations des différents champs
  TextEditingController nomTontine=TextEditingController();
  TextEditingController montantCotisation=TextEditingController();
  TextEditingController nombreParticipant=TextEditingController();
  TextEditingController montantPenalite=TextEditingController();

  Future<void>typeTontines()async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=type_tontine&action=type_dispo");
    final reponse=await http.get(url);
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']){
        List<dynamic>list=data['data'];
        setState(() {
          typeTontine=list.map<String>((item)=>item['type_tontine'].toString()).toList();
        });
      }else{
        print(data['message']);
      }

    }else{
      print(reponse.statusCode);
    }
  }


  Future<void>frequenceTontines()async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=type_tontine&action=lister_frequence");
    final reponse=await http.get(url);
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']){
        List<dynamic>list=data['data'];
        setState(() {
          frequenceCotisa=list.map<String>((item)=>item['frequence'].toString()).toList();
        });
      }else{
        print(data['message']);
      }

    }else{
      print(reponse.statusCode);
    }
  }
  
  
  Future<void>creerTontine() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=creer_tontine");
    final reponse=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "nom_tontine":nomTontine.text,
          "type_tontine":_typeChoisi,
          "montant_cotisation":int.parse(montantCotisation.text),
          "nombre_participant":int.parse(nombreParticipant.text),
          "frequence":_frequenceChoisi
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']){
        final Map<String,dynamic>donnee=data['data'];
        print(donnee['code_tontine']);
        setState(() {
          widget.listsession.setCodeTontine(donnee['code_tontine']);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession,)), (route)=>false);
        });
        print(widget.listsession.code_tontine);
      }else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Erreur"),),
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
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Créer une tontine",style: TextStyle(fontWeight: FontWeight.bold),),),
      ),
      body: Padding(padding: EdgeInsets.only(left: 10.0,right: 10.0),
      child: Column(
        children: [
          SizedBox(height: 20.0,),
          TextField(
            controller: nomTontine,
            decoration: InputDecoration(
              label: Text('Nom tontine'),
              filled: true,
              fillColor: couleur.lightGray,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: couleur.primaryPurple),
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

              )
            ),
          ),
          SizedBox(height: 15.0,),
          TextField(
            controller: montantCotisation,
            decoration: InputDecoration(
                label: Text('Montant de cotisation'),
                filled: true,
                fillColor: couleur.lightGray,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: couleur.primaryPurple
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                )
            ),
          ),
          SizedBox(height: 10.0,),
          TextField(
            controller: nombreParticipant,
            decoration: InputDecoration(
                label: Text('Nombre de participant'),
                filled: true,
                fillColor: couleur.lightGray,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: couleur.primaryPurple
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                )
            ),
          ),
          SizedBox(height: 10.0,),

          //Sélectionner le type de tontine
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Sélectionner le type de tontine",
                filled: true,
                fillColor: couleur.lightGray,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF7E57C2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF5E35B1), width: 2),
                ),
              ),
              hint:Text("Sélectionner le type de tontine"),
              value:_typeChoisi,
              items: typeTontine.map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(value: value,child:Text(value),);
              }).toList(), onChanged: (String? _nouvelleValeur){
            setState(() {
              _typeChoisi=_nouvelleValeur;
            });
          }),
          SizedBox(height: 10.0,),

          //Sélectionner les fréquences de cotisations
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Sélectionner la fréquence des cotisations",
                filled: true,
                fillColor: couleur.lightGray,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF7E57C2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF5E35B1), width: 2),
                ),
              ),
              hint:Text("Sélectionner la fréquence des cotisations"),
              value:_frequenceChoisi,
              items: frequenceCotisa.map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(value: value,child:Text(value),);
              }).toList(), onChanged: (String? _nouvelleValeur){
            setState(() {
              _frequenceChoisi=_nouvelleValeur;
            });
          }),
          SizedBox(height: 10.0,),
          TextField(
            controller: montantPenalite,
            decoration: InputDecoration(
                label: Text('Montant de pénalité'),
                filled: true,
                fillColor: couleur.lightGray,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: couleur.primaryPurple
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: couleur.primaryPurple
                    )
                )
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: TextButton(onPressed: (){
              creerTontine();
            }, child: Text("Valider",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),style: TextButton.styleFrom(
              backgroundColor: couleur.primaryPurple
            ),),
          )

        ],
      ),),
    );
  }
}
