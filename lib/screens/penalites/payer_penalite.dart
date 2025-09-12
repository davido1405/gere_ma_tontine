import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/penalites.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../../constants/colors.dart';
import '../../constants/server.dart';

class payer_penalite extends StatefulWidget {
  final Session listsession;
  const payer_penalite({super.key, required this.listsession});

  @override
  State<payer_penalite> createState() => _payer_penaliteState();
}

class _payer_penaliteState extends State<payer_penalite> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPenalite();

    montant.addListener((){
      if (misejourEncour) return;
      misejourEncour = true;
      double somme=double.tryParse(montant.text) ?? 0;
      double total=(somme+(0.1 * somme));
      montantFraisinculs.text=total.toStringAsFixed(2);
      misejourEncour = false;
    });
    montantFraisinculs.addListener((){
      if (misejourEncour) return;
      misejourEncour = true;
      double somme2=double.tryParse(montant.text) ?? 0;
      double total=(somme2-(0.1 * somme2));
      montant.text=total.toStringAsFixed(2);
      misejourEncour = false;
    });
  }


  @override
  void dispose(){
    montant.dispose();
    montantFraisinculs.dispose();
    super.dispose();
  }


  bool misejourEncour=false;
  String _selectedOption ="";


  TextEditingController montant=TextEditingController();

  TextEditingController montantFraisinculs=TextEditingController();

  List<Penalite>_listPenalite=[];

  Future<void> fetchPenalite() async{
    final url=Uri.parse("${adress}?ressource=cotisations&action=voir_mes_penalites");
    final response = await post(url,headers: {'content-Type':'application/json'},body: jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    }));
    if(response.statusCode==200){
      final Map <String,dynamic> data =jsonDecode(response.body);
      List<dynamic>pena=data['data'];
      setState(() {
        _listPenalite=pena.map((pena)=>Penalite.fromJson(pena)).toList();
      });
    }
  }

  Future<void>payerPenalite(String x, String y) async{
    final url=Uri.parse("${adress}?ressource=cotisations&action=payer_penalite");
    final reponse=await http.post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine,
          "code_participant":widget.listsession.code_participant,
          "montant":int.parse(x),
          "libelle_mode_paiement":y
        }));
    if(reponse.statusCode==200){
      Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Statut paiement",style: TextStyle(
                fontSize: 15.sp
            ),),),
            content: Text(data['message'],style: TextStyle(
                fontSize: 14.sp
            ),),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                }, label: Text("OK",style: TextStyle(
                    fontSize: 14.sp
                ),),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
              )
            ],
          );
        });
      }else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(
              child: Text("Statut paiement",style: TextStyle(
                  fontSize: 15.sp
              ),),
            ),
            content: Text(data['message'],style: TextStyle(
                fontSize: 14.sp
            ),),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                }, label: Text("OK",style: TextStyle(
                    fontSize: 14.sp
                ),),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
              )
            ],
          );
        });
      }
    }else{
      print("Erreur serveur : ${reponse.statusCode}");
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
        title: Text("Pénalités",
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold
          ),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchPenalite,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.w),
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: montant,
                  decoration: InputDecoration(
                      label: Text("Montant (Exemple: 2000)",style: TextStyle(
                          fontSize: 14.sp
                      ),),
                      fillColor: couleur.lightGray,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      )
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: montantFraisinculs,
                  decoration: InputDecoration(
                      label: Text("Montant frais inclus(1%)",style: TextStyle(
                          fontSize: 14.sp
                      ),),
                      fillColor: couleur.lightGray,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      )
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: (){
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.r)),
                                    height: 250.h,
                                    width: double.maxFinite,
                                    child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 20,
                                                  child: Card(
                                                      color: couleur.lightGray,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: (){
                                                            setModalState(() {
                                                              _selectedOption="Wave";
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: 50.w,
                                                                child: Image.asset("assets/wave.png",fit: BoxFit.cover,),
                                                              ),
                                                              RadioListTile<String>(value: "Wave", groupValue: _selectedOption, onChanged: (value){
                                                                setState(() {
                                                                  _selectedOption=value!;
                                                                });
                                                              })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 20,
                                                  child: Card(
                                                      color: couleur.lightGray,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: (){
                                                            setModalState(() {
                                                              _selectedOption="Orange Money";
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                height: 50.h,
                                                                width: 50.w,
                                                                child: Image.asset("assets/orange.png",fit: BoxFit.cover,),
                                                              ),
                                                              RadioListTile<String>(value: "Orange Money", groupValue: _selectedOption, onChanged: (value){
                                                                setState(() {
                                                                  _selectedOption=value!;
                                                                });
                                                              })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 20,
                                                  child: Card(
                                                      color: couleur.lightGray,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: (){
                                                            setModalState(() {
                                                              _selectedOption="MTN Money";
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                height: 50.h,
                                                                width: 60.w,
                                                                child: Image.asset("assets/mtn.png",fit: BoxFit.cover,),
                                                              ),
                                                              RadioListTile<String>(value: "MTN Money", groupValue: _selectedOption, onChanged: (value){
                                                                setState(() {
                                                                  _selectedOption=value!;
                                                                });
                                                              })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 20,
                                                  child: Card(
                                                      color: couleur.lightGray,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: (){
                                                            setModalState(() {
                                                              _selectedOption="Moov Money";
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: 50.w,
                                                                height: 50.h,
                                                                child: Image.asset("assets/moov.png",fit: BoxFit.cover,),
                                                              ),
                                                              RadioListTile<String>(value: "Moov Money", groupValue: _selectedOption, onChanged: (value){
                                                                setState(() {
                                                                  _selectedOption=value!;
                                                                  print(_selectedOption.toString());
                                                                });
                                                              })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30.h,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                                            child: Row(
                                              children: [
                                                Expanded(child: ElevatedButton.icon(onPressed: (){
                                                  String montantPaiement=montant.text;
                                                  String modePaie=_selectedOption.toString();
                                                  payerPenalite(montantPaiement, modePaie);
                                                }, label: Text("Valider paiement"),icon: Icon(Icons.verified,color: Colors.green,),))
                                              ],
                                            ),
                                          )
                                        ]),
                                  );}
                            );
                          });}, label: Text("Payer",style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),),icon: Icon(Icons.attach_money_sharp,color: Colors.white,),style: ElevatedButton.styleFrom(
                      backgroundColor: couleur.primaryPurple,
                    ),))
                  ],
                ),
                SizedBox(
                  height:20.h,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 150.w),
                  child: Column(
                    children: [
                      Text("Historique des pénalité",style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(
                        height: 15.h,
                      ),
                      SizedBox(
                        height: 400.h,
                        child: Column(
                          children: [
                            Expanded(
                                child: ListView.builder(
                                    itemCount: _listPenalite.length,
                                    itemBuilder: (context,index){
                                      final Penalite penalite=_listPenalite[index];
                                      return ListTile(
                                        title: Text(penalite.raison+"    "+penalite.date_penalite,style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold
                                        ),),
                                        subtitle: Text("Montant "+penalite.montant+" FCFA          "+penalite.statut,style: TextStyle(
                                          fontSize: 14.sp
                                        ),),
                                      );
                                    })
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
