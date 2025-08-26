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

  String ? _selectedOption ="Mobile Money";

  TextEditingController montant=TextEditingController();

  List<Penalite>_listPenalite=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPenalite();
  }
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
            padding: EdgeInsets.only(left: 15.0.w,right: 15.0.w),
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                ),
                TextField(
                  controller: montant,
                  decoration: InputDecoration(
                      label: Text("Montant",style: TextStyle(
                        fontSize: 16.sp
                      ),),
                      fillColor: couleur.lightGray,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: couleur.primaryPurple)
                      )
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 200.w),
                  child: Column(
                    children: [
                      Text("Mode de paiement",style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(
                        height: 15.h,
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Card(
                        color: couleur.lightGray,
                        child: Padding(padding: EdgeInsets.only(left: 5.w),child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage("assets/wave.png"),
                            ),
                            Text("Wave",style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: couleur.secondaryText
                            ),
                            ),
                            Radio(value: "Wave", groupValue: _selectedOption, onChanged: (value){
                              setState(() {
                                _selectedOption=value;
                              });
                            })
                          ],
                        ),)
                    ))
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: (){
                      String montantPay=montant.text;
                      String modePai=_selectedOption.toString();
                      payerPenalite(montantPay,modePai);
                    }, label: Text("Payer",style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),),icon: Icon(Icons.attach_money_sharp,color: Colors.white,),style: ElevatedButton.styleFrom(
                      backgroundColor: couleur.primaryPurple,
                    ),))
                  ],
                ),
                SizedBox(
                  height:10.h,
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
