import 'dart:convert';
import 'dart:convert' as convert;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/cotisation.dart';
import 'package:gerematontine/models/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/colors.dart';


class payer_cotisation extends StatefulWidget {
  final Session listsession;
  const payer_cotisation( {super.key, required this.listsession});

  @override
  State<payer_cotisation> createState() => _payer_cotisationState();
}

class _payer_cotisationState extends State<payer_cotisation> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCotisation();
  }
  List<Cotisation>_listCotisation=[];

  String ? _selectedOption ="Wave";
  TextEditingController montant=TextEditingController();


  Future<void>fetchCotisation() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=cotisations&action=voir_mes_cotisations");
    final response = await http.post(url,headers: {'content-Type':'application/json'},body: convert.jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    }));
    if(response.statusCode==200){
      final Map <String,dynamic> data =convert.jsonDecode(response.body);
      List<dynamic>coti=data['data'];
      setState(() {
        _listCotisation=coti.map((coti)=>Cotisation.fromJson(coti)).toList();
      });
    }
  }

  Future<void>payerCotisation(String x, String y) async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=cotisations&action=payer_cotisation");
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
            title: Center(child: Text("Statut paiement"),),
            content: Text(data['message']),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
              )
            ],
          );
        });
      }else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(
              child: Text("Statut paiement"),
            ),
            content: Text(data['message']),
            actions: [
              Center(
                child: TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Cotisations",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchCotisation,
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
                    label: Text("Montant (Exemple: 2000)",style: TextStyle(
                      fontSize: 14.sp
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
                  height: 25.h,
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
                  height: 15.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: (){
                      String montantPay=montant.text;
                      String modePai=_selectedOption.toString();
                      payerCotisation(montantPay,modePai);
                      montant.clear();
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
                  height:20.h,
                ),
              Padding(
                padding: EdgeInsets.only(right: 150.w),
                child: Column(
                  children: [
                    Text("Historique de cotisation",style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold
                ),)
                  ],
                ),
              ),
                SizedBox(
                height: 10.h,
              ),
              SizedBox(
                height: 425.h,
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: _listCotisation.length,
                            itemBuilder: (context,index){
                              final Cotisation cotisa=_listCotisation[index];
                              return GestureDetector(
                                onTap: (){
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Center(
                                        child: Text("Détails cotisation",style:
                                          TextStyle(
                                            fontSize: 18.sp
                                          ),),
                                      ),
                                      content: SizedBox(
                                        height: 125.h,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text("Code transaction : ${cotisa.code_cotisation}",style: TextStyle(
                                                  fontSize: 14.sp
                                                ),)
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Row(
                                              children: [
                                                Text("Montant transaction : ${cotisa.montant} FCFA",style: TextStyle(
                                                    fontSize: 14.sp
                                                ),)
                                              ],
                                            ),SizedBox(
                                              height: 5.h,
                                            ),
                                            Row(
                                              children: [
                                                Text("Mode de paiement : ${cotisa.mode_paiement}",style: TextStyle(
                                                    fontSize: 14.sp
                                                ),)
                                              ],
                                            ),SizedBox(
                                              height: 5.h,
                                            ),
                                            Row(
                                              children: [
                                                Text("Date de transaction : ${cotisa.date_paiement}",style: TextStyle(
                                                    fontSize: 14.sp
                                                ),)
                                              ],
                                            ),SizedBox(
                                              height: 5.h,
                                            ),
                                            Row(
                                              children: [
                                                Text("Satut de transaction : ${cotisa.statut_paiement}",style: TextStyle(
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
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(cotisa.code_cotisation,style: TextStyle(
                                            fontSize: 15.sp,
                                          fontWeight: FontWeight.bold
                                        ),),
                                        Text(cotisa.date_paiement.split(" ")[0],style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold
                                        ),)
                                      ],
                                    ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Montant: "+cotisa.montant+" FCFA",style: TextStyle(
                                        fontSize: 14.sp
                                    ),),
                                    Text(cotisa.statut_paiement,style: TextStyle(
                                      color: Colors.green,
                                        fontSize: 14.sp
                                    ),),
                                  ],

                                ),
                                ),
                              );
                            })
                    ),
                  ],
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
