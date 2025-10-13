import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../constants/server.dart';
import '../auth/verifier_profil_kyc.dart';

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
    frequencePaiementTontines();
  }
  
  List<String>typeTontine=[];

  List<String>frequenceCotisa=[];
  List<String>frequencePaiemen=[];

  String? _typeChoisi;

  String? _frequenceChoisi;
  String?_frequencePaiementChoisi;



  //Récupération des informations des différents champs
  TextEditingController nomTontine=TextEditingController();
  TextEditingController montantCotisation=TextEditingController();
  TextEditingController nombreParticipant=TextEditingController();
  TextEditingController montantPenalite=TextEditingController();

  Future<void>typeTontines()async{
    final url=Uri.parse("${adress}?ressource=type_tontine&action=type_dispo");
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
    final url=Uri.parse("${adress}?ressource=type_tontine&action=lister_frequence");
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
//Lister frequence paiement
  Future<void>frequencePaiementTontines()async{
    final url=Uri.parse("${adress}?ressource=type_tontine&action=lister_frequence_paiement");
    final reponse=await http.get(url);
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']){
        List<dynamic>list=data['data'];
        setState(() {
          frequencePaiemen=list.map<String>((item)=>item['frequence_paiement'].toString()).toList();
        });
      }else{
        print(data['message']);
      }

    }else{
      print(reponse.statusCode);
    }
  }
  
  
  Future<void>creerTontine() async{
    String? jwt=await widget.listsession.getSecureJwt();

    //Afficher dialogue pendent chargement
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: SizedBox(
          height: 200.h,
          child: Center(
            child: Column(
              children: [
                Lottie.asset("assets/animations/lottieflow-scrolling-01-2-000000-easey.json",width: 150.w,height: 150.h),
                Text("Traitement en cours...")
              ],
            ),
          ),
        ),
      );
    });
    final url=Uri.parse("${adress}?ressource=tontines&action=creer_tontine");
    final reponse=await http.post(url,headers: {'content-Type':'application/json','Authorization':'Bearer $jwt'},body: jsonEncode({
          "code_participant":widget.listsession.code_participant,
          "nom_tontine":nomTontine.text,
          "type_tontine":_typeChoisi,
          "montant_cotisation":int.parse(montantCotisation.text),
          "nombre_participant":int.parse(nombreParticipant.text),
          "frequence":_frequenceChoisi,
          "frequence_paiement":_frequencePaiementChoisi,
        }));

    //Fermer le dialogue de chargement
    Navigator.of(context).pop();

    //print(widget.listsession.code_participant);
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']){
        final Map<String,dynamic>donnee=data['data'];
        //print(donnee['code_tontine']);
        setState(() {
          widget.listsession.setCodeTontine(donnee['code_tontine']);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>dashboard(listsession: widget.listsession,)), (route)=>false);
        });
        //print(widget.listsession.code_tontine);
      }else{
        if(data['message']=="Votre niveau de vérification est insuffisant pour réjoindre cette tontine. Veuillez fournir des informations supplémentaire à votre identification. Merci"){
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Center(child: Text("Erreur"),),
              content: SizedBox(
                  height: 200.h,
                  child: Center(
                    child: Column(
                      children: [
                        Lottie.asset("assets/animations/Sign for error _ Flat style.json",width: 150.w,height: 150.h),
                    Text("Niveau de vérification insuffisant pour créer une tontine avec ce montant de cotisation.",overflow: TextOverflow.ellipsis,maxLines: 2,),
                      ],
                    ),
                  )),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(backgroundColor: Couleur.primaryBlue),
                          label: Text("Compris", style: TextStyle(color: Colors.white)),
                          icon: Icon(Icons.verified, color: Colors.white)),
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>verifier_profil_kyc()));
                          },
                          style: TextButton.styleFrom(backgroundColor: Couleur.accentOrange),
                          label: Text("Vérifier compte", style: TextStyle(color: Colors.white)),
                          icon: Icon(Icons.verified_user_rounded, color: Colors.white)),
                    ],
                  ),
                )
              ],
            );
          });
        }else{
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Center(child: Text("Erreur"),),
              content: SizedBox(
                  height: 200.h,
                  child: Center(
                    child: Column(
                      children: [
                        Lottie.asset("assets/animations/Sign for error _ Flat style.json",width: 150.w,height: 150.h),
                        Text("Une erreur s'est produite veuillez contacter le service technique"),
                      ],
                    ),
                  )),
              actions: [
                Center(
                  child: TextButton.icon(onPressed: (){
                    Navigator.of(context).pop();
                  }, label: Text("Compris",style: TextStyle(
                      color: Colors.white
                  ),),icon: Icon(Icons.verified,color: Colors.white,),style: TextButton.styleFrom(
                      backgroundColor: Couleur.secondaryGreen
                  ),),
                )
              ],
            );
          });
        }
      }
    }else{
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Center(child: Text("Erreur"),),
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset("assets/animations/Sign for error _ Flat style.json",width: 150.w,height: 150.h),
                Text("Une erreur s'est produite,veuillez réessayer plus tard ou contacter le service technique",overflow: TextOverflow.ellipsis,maxLines: 2,),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton.icon(onPressed: (){
                Navigator.of(context).pop();
              }, label: Text("Compris",style: TextStyle(
                  color: Colors.white
              ),),icon: Icon(Icons.verified,color: Colors.white,),style: TextButton.styleFrom(
                  backgroundColor: Couleur.secondaryGreen
              ),),
            )
          ],
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Center(child: Text("Créer une tontine",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold),),),
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0.w),
      child: Column(
        children: [
          SizedBox(height: 20.0.h,),
          TextField(
            controller: nomTontine,
            decoration: InputDecoration(
              label: Text('Nom tontine',style: TextStyle(
                fontSize: 16.sp
              ),),
              filled: true,
              fillColor: Couleur.lightGray,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Couleur.primaryBlue),
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),

              )
            ),
          ),
          SizedBox(height: 15.0.h,),
          TextField(
            controller: montantCotisation,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                label: Text('Montant de cotisation',style: TextStyle(
                    fontSize: 16.sp
                ),),
                filled: true,
                fillColor: Couleur.lightGray,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                        color: Couleur.primaryBlue
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                )
            ),
          ),
          SizedBox(height: 10.0.h,),
          TextField(
            controller: nombreParticipant,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                label: Text('Nombre de participant',style: TextStyle(
                    fontSize: 16.sp
                ),),
                filled: true,
                fillColor: Couleur.lightGray,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                        color: Couleur.primaryBlue
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                )
            ),
          ),
          SizedBox(height: 10.0.h,),

          //Sélectionner le type de tontine
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: Text("Sélectionner le type de tontine",style: TextStyle(
                    fontSize: 16.sp
                ),),
                filled: true,
                fillColor: Couleur.lightGray,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue, width: 2.w),
                ),
              ),
              hint:Text("Sélectionner le type de tontine",style: TextStyle(
                  fontSize: 16.sp
              ),),
              value:_typeChoisi,
              items: typeTontine.map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(value: value,child:Text(value),);
              }).toList(), onChanged: (String? _nouvelleValeur){
            setState(() {
              _typeChoisi=_nouvelleValeur;
            });
          }),
          SizedBox(height: 10.0.h,),

          //Sélectionner les fréquences de cotisations
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: Text("Sélectionner la fréquence des cotisations",style: TextStyle(
                    fontSize: 16.sp
                ),),
                filled: true,
                fillColor: Couleur.lightGray,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue, width: 2.w),
                ),
              ),
              hint:Text("Sélectionner la fréquence des cotisations",style: TextStyle(
                  fontSize: 16.sp
              ),),
              value:_frequenceChoisi,
              items: frequenceCotisa.map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(value: value,child:Text(value),);
              }).toList(), onChanged: (String? _nouvelleValeur){
            setState(() {
              _frequenceChoisi=_nouvelleValeur;
            });
          }),
          SizedBox(height: 10.0.h,),
          //Sélectionner les fréquences des paiements
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: Text("Sélectionner la fréquence des paiements",style: TextStyle(
                    fontSize: 16.sp
                ),),
                filled: true,
                fillColor: Couleur.lightGray,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Couleur.primaryBlue, width: 2.w),
                ),
              ),
              hint:Text("Sélectionner la fréquence des paiements",style: TextStyle(
                  fontSize: 16.sp
              ),),
              value:_frequencePaiementChoisi,
              items: frequencePaiemen.map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(value: value,child:Text(value),);
              }).toList(), onChanged: (String? _nouvelleValeur){
            setState(() {
              _frequencePaiementChoisi=_nouvelleValeur;
            });
          }),
          SizedBox(height: 20.0.h,),
          Center(
            child: ElevatedButton(onPressed: (){
              creerTontine();
            },style: TextButton.styleFrom(
              backgroundColor: Couleur.primaryBlue
            ), child: Text("Terminer",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold,color: Colors.white),),),
          )

        ],
      ),),
    );
  }
}
