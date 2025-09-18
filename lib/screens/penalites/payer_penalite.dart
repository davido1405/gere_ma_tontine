import 'dart:convert';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
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
  }

  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;

  bool enCourtraitement=false;

  String _selectedOption ="";


  TextEditingController montant=TextEditingController();

  TextEditingController montantFraisinculs=TextEditingController();

  List<Penalite>_listPenalite=[];

  Future<void> fetchPenalite() async{
    String? jwt=await widget.listsession.getSecureJwt();
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
    final reponse=await http.post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer ${widget.listsession.getSecureJwt()}"},body: jsonEncode(
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
        bottom: TabBar(tabs: [
          Tab(icon: Icon(Icons.shield),),
          Tab(icon: Icon(Icons.assured_workload),)
        ]),
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
                  onTap: (){
                    saisiMontant=true;
                  },
                  onEditingComplete: (){
                    saisiMontant=false;
                  },
                  onChanged: (value){
                    if(value.isEmpty) {
                      montantFraisinculs.clear();
                      return;
                    }
                    double somme = double.tryParse(montant.text) ?? 0;
                    double total= somme - (0.1 * somme);
                    final newTotal=total.toStringAsFixed(0);
                    montantFraisinculs.value=TextEditingValue(
                        text: newTotal,
                        selection: TextSelection.collapsed(offset: newTotal.length)
                    );
                  },
                  decoration: InputDecoration(
                      label: Text("Montant Hors Frais(Exemple: 2000)",style: TextStyle(
                          fontSize: 14.sp
                      ),),
                      fillColor: Couleur.lightGray,
                      filled: true,

                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Couleur.primaryBlue,width: 2.0.w),
                      )
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: montantFraisinculs,
                  onTap: (){
                    saisiMontantFrais=true;
                  },
                  onEditingComplete: (){
                    saisiMontantFrais=false;
                  },
                  onChanged: (value){
                    if(value.isEmpty) {
                      montant.clear();
                      return;
                    }

                    double somme2=double.tryParse(montantFraisinculs.text) ?? 0;
                    double total2=somme2 + (0.1 * somme2);

                    final newTotal2=total2.toStringAsFixed(0);
                    montant.value=TextEditingValue(
                        text: newTotal2,
                        selection: TextSelection.collapsed(offset: newTotal2.length)
                    );
                  },
                  decoration: InputDecoration(
                      label: Text("Montant + Frais",style: TextStyle(
                          fontSize: 14.sp
                      ),),
                      fillColor: Couleur.lightGray,
                      filled: true,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Couleur.primaryBlue,width: 2.0.w),
                      )
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("Frais Djarra Finances 1%",style: TextStyle(
                    fontSize: 15.sp,
                    color: Couleur.primaryBlue
                ),),
                SizedBox(
                  height: 10.h,
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
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12.r)),
                                    height: 400.h,
                                    width: double.maxFinite.w,
                                    child: Column(
                                        children: [
                                          SizedBox(
                                            height: 15.h,
                                          ),
                                          Center(
                                            child: Text("Mode de paiement",style: TextStyle(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w500
                                            ),),
                                          ),SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Couleur.lightGray,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                      child: InkWell(
                                                        splashColor: Colors.blueAccent.withOpacity(0.2),
                                                        highlightColor: Colors.transparent,
                                                        onTap: (){
                                                          setModalState(() {
                                                            _selectedOption="Wave";
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                                flex:3,
                                                                child: Row(children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(5.r),
                                                                    child: Image.asset("assets/wave.png",fit: BoxFit.cover,height: 50.h,
                                                                      width: 100.w,),
                                                                  ),
                                                                  SizedBox(width: 10.w,),
                                                                  Text("WAVE"),
                                                                ],)),
                                                            SizedBox(width: 60.w,),
                                                            Expanded(
                                                              flex:1,
                                                              child: RadioListTile<String>(value: "Wave", groupValue: _selectedOption, onChanged: (value){
                                                                setModalState(() {
                                                                  _selectedOption=value!;
                                                                  print(_selectedOption.toString());
                                                                });
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Couleur.lightGray,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                      child: InkWell(
                                                        splashColor: Colors.deepOrange.withOpacity(0.2),
                                                        highlightColor: Colors.transparent,
                                                        onTap: (){
                                                          setModalState(() {
                                                            _selectedOption="Orange Money";
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                                flex:3,
                                                                child: Row(children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(5.r),
                                                                    child: Image.asset("assets/orange money 2.png",fit: BoxFit.cover,height: 50.h,
                                                                      width: 100.w,),
                                                                  ),
                                                                  SizedBox(width: 10.w,),
                                                                  Text("ORANGE"),
                                                                ],)),
                                                            SizedBox(width: 70.w,),
                                                            Expanded(
                                                              flex: 1,
                                                              child: RadioListTile<String>(value: "Orange Money", groupValue: _selectedOption, onChanged: (value){
                                                                setModalState(() {
                                                                  _selectedOption=value!;
                                                                  print(_selectedOption.toString());
                                                                });
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Couleur.lightGray,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                      child: InkWell(
                                                        splashColor: Colors.yellow.withOpacity(0.5),
                                                        highlightColor: Colors.transparent,
                                                        onTap: (){
                                                          setModalState(() {
                                                            _selectedOption="MTN Money";
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                                flex:3,
                                                                child: Row(children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(5.r),
                                                                    child: Image.asset("assets/MTN MONEY.png",fit: BoxFit.cover,height: 50.h,
                                                                      width: 100.w,),
                                                                  ),
                                                                  SizedBox(width: 10.w,),
                                                                  Text("MTN"),
                                                                ],
                                                                )
                                                            ),
                                                            SizedBox(width: 70.w,),
                                                            Expanded(
                                                              flex: 1,
                                                              child: RadioListTile<String>(value: "MTN Money", groupValue: _selectedOption, onChanged: (value){
                                                                setModalState(() {
                                                                  _selectedOption=value!;
                                                                  print(_selectedOption.toString());
                                                                });
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Couleur.lightGray,
                                                    child: InkWell(
                                                      splashColor: Colors.blueAccent.withOpacity(0.5),
                                                      highlightColor: Colors.transparent,
                                                      onTap: (){
                                                        setModalState(() {
                                                          _selectedOption="Moov Money";
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              flex:3,
                                                              child: Row(children: [
                                                                ClipRRect(
                                                                  borderRadius: BorderRadius.circular(14.r),
                                                                  child: Image.asset("assets/moov.png",fit: BoxFit.cover,height: 50.h,
                                                                    width: 110.w,),
                                                                ),
                                                                SizedBox(width: 10.w,),
                                                                Text("MOOV"),
                                                              ],)),
                                                          SizedBox(width: 70.w,),
                                                          Expanded(
                                                            flex: 1,
                                                            child: RadioListTile<String>(value: "Moov Money", groupValue: _selectedOption, onChanged: (value){
                                                              setModalState(() {
                                                                _selectedOption=value!;
                                                                print(_selectedOption.toString());
                                                              });
                                                            }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 100.w),
                                            child: Row(
                                              children: [
                                                Expanded(child: ElevatedButton.icon(onPressed: enCourtraitement? null: (){
                                                  String montantPaiement=montant.text;
                                                  String modePaie=_selectedOption.toString();
                                                  if(montantPaiement.isEmpty || modePaie.isEmpty){
                                                    DelightToastBar(
                                                      position: DelightSnackbarPosition.top,
                                                      autoDismiss: true,
                                                      snackbarDuration: Duration(seconds: 2),
                                                      builder: (BuildContext context) {
                                                        return ToastCard(
                                                          title: Row(
                                                            mainAxisAlignment:MainAxisAlignment.start,
                                                            children: [Icon(Icons.error_outline,color: Colors.white,size: 30.r,),Text("Veuillez remplir tout les champs !",style: TextStyle(
                                                                color: Colors.white
                                                            ),)],),
                                                          color: Colors.red.shade700,);
                                                      },).show(context);
                                                  }else{
                                                    print(montantPaiement);
                                                    print(montant.text);
                                                    payerPenalite(montantPaiement, modePaie);
                                                  }
                                                },style: TextButton.styleFrom(
                                                    backgroundColor: Colors.blueAccent
                                                ), label:enCourtraitement?Text("Paiement en cours..."):Text("Payer"),icon:enCourtraitement?SizedBox(width:20.w,height:20.h,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)):Icon(Icons.monetization_on,color: Colors.white,),))
                                              ],
                                            ),
                                          )
                                        ]),
                                  );}
                            );
                          });}, label: Text("Valider le paiement",style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),),icon: Icon(Icons.arrow_forward_ios,color: Colors.white,),style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
