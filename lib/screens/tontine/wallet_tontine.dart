import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/models/transactions.dart';
import 'package:gerematontine/models/wallet_tontine.dart';
import 'package:http/http.dart';

import '../../models/session.dart';

class walletTontine extends StatefulWidget {
  final Tontine tontine;
  final Session listsession;
  final int numeroTour;
  const walletTontine({super.key,required this.listsession,required this.tontine,required this.numeroTour});

  @override
  State<walletTontine> createState() => _walletTontineState();
}

class _walletTontineState extends State<walletTontine> {

  //Initialisation de toutes mes fonction
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recupererWallet();
    transacs();
    verifierTour();
    Future.delayed(Duration(seconds: 2),(){
      if(mounted){
        setState(() {
          _ouvert=false;
        });
      }
    });
  }
  WalletTontine? wallet;
  List<Transactions>_listeTransac=[];
  bool _ouvert=true;
  bool _monTour=false;
  
  //Recupérer le wallet
  Future<void>recupererWallet() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=wallet_infos");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_tontine":widget.tontine.code_tontine
        }));
    if(reponse.statusCode==200){
      Map<String,dynamic>data=jsonDecode(reponse.body);
      if(data['success']==true){
        var infos=data['data'];
        if(infos!=null){
          setState(() {
            wallet=WalletTontine.fromJson(infos);
          });
        }
      }
    }
  }

  //Récupérer la liste des transactions
Future<void>transacs() async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=transactions");
    final response=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_tontine":widget.tontine.code_tontine
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(response.body);
      if(data['success']==true){
        final List<dynamic>donnee=data['data'];
        if(donnee!=null){
          setState(() {
            _listeTransac=donnee.map((donnee)=>Transactions.fromJson(donnee)).toList();
          });
        }
      }
    }
}

Future<void>verifierTour()async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=participants&action=verifierTour");
    final response=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
        "code_tontine":widget.tontine.code_tontine
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>donnee=jsonDecode(response.body);
      if(donnee['success']==true){
        var tour=donnee['data'];
        if(widget.listsession.code_participant==tour['code_participant'] && widget.numeroTour==tour['ordre']){
          setState(() {
            _monTour=true;
          });
        }
      }
    }
}

Future<void>retirer()async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=tontines&action=retirer");
    final response=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine,
          "code_participant":widget.listsession.code_participant
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>donnee=jsonDecode(response.body);
      if(donnee['success']==true){
        var cheque=donnee['data'];
        print(cheque);
        if(cheque!=0){
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Center(child: Text("Félicitation"),),
              content: Text("Retrait éffectué avec succès !"),
              actions: [
                TextButton.icon(onPressed: (){
                  Navigator.of(context).pop();
                  initState();
                }, label: Text("Merci !"),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
              ],
            );
          });
        }
      }else{
        print(donnee['message']);
      }
    }else{
      print(response.statusCode);
    }
}



  @override
  Widget build(BuildContext context) {
    if(wallet==null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Compte de tontine",style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 175,
              child: Card(
                color: couleur.primaryPurple,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Montant en caisse",style: TextStyle(
                                fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              TweenAnimationBuilder(tween: Tween(begin: 0,end: double.parse(wallet!.solde_tontine.toString())), duration: Duration(seconds: 2), builder: (context,value,child){
                                return Text(
                                  value.toStringAsFixed(2)+" FCFA",style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ));
                              })
                            ],
                          ),
                          Center(
                            child: Row(
                              children: [
                                Center(
                                  child: TextButton.icon(onPressed: (){
                                    if(_monTour){
                                      retirer();
                                    }else{
                                      showDialog(context: context, builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Center(child: Text("Oups !"),),
                                          content: Text("Vous prenez en position ${widget.numeroTour}"),
                                          actions: [
                                            Center(child: TextButton.icon(onPressed: (){
                                              Navigator.of(context).pop();
                                            }, label: Text("Compris !"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
                                          ],
                                        );
                                      });
                                    }
                                  }, label: Text("Retrait"),icon: Icon(Icons.arrow_downward),style: TextButton.styleFrom(
                                    backgroundColor: _monTour?Colors.white:Colors.grey
                                  ),),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(_ouvert?Icons.lock_open:Icons.lock_outline,size: 80,color: _ouvert? Colors.red:Colors.green,),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 5,
              color: Colors.grey[400],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.compare_arrows,size: 25,),
                SizedBox(
                  width: 10,
                ),
                Text("Historique des transactions",style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 550,
              child: Expanded(child: ListView.builder(
                  itemCount: _listeTransac.length,
                  itemBuilder: (context,index){
                    final Transactions transac=_listeTransac[index];
                return GestureDetector(
                  onTap: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        title: Center(child: Text("Détails de transaction")),
                        content: Container(
                          height: 145,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nom :"+transac.nom),
                              Text("Prénoms :"+transac.prenoms),
                              Text("Type de transaction :"+transac.type_transaction),
                              Text("Montant de transaction :"+transac.montant_transaction),
                              Text("Date de transaction :"+transac.date_transaction),
                              Text("Mode de paiement :"+transac.mode_paiement),
                              Text(transac.statut_paiement==2?"Statut: Payée":"Statut: En attente"),
                            ],
                          ),
                        ),
                        actions: [
                          Center(
                            child: TextButton.icon(onPressed: (){
                              Navigator.of(context).pop();
                            }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),
                          )
                        ],
                      );
                    });
                  },
                  child: ListTile(
                    title: Text((widget.listsession.nom_participant==transac.nom && widget.listsession.prenoms_participant==transac.prenoms)? "Vous":transac.prenoms+" "+transac.nom, style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transac.type_transaction),
                            Text(transac.date_transaction)
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(transac.type_transaction!="Retrait" ? "+ "+transac.montant_transaction.toString():"- "+transac.montant_transaction.toString(),style: TextStyle(
                                color:(transac.type_transaction=="Retrait")?  Colors.red:Colors.green,
                                  fontWeight: FontWeight.bold
                                ),),
                                Text(transac.statut_paiement)
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Icon(transac.type_transaction!="Retrait"? Icons.arrow_outward:Icons.arrow_downward,color:transac.type_transaction!="Retrait"? Colors.green:Colors.red,size: 20)
                              ],
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                );})),
            )
          ],
        ),
      ),
    );
  }
}
