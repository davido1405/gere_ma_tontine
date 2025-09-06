import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/models/transactions.dart';
import 'package:gerematontine/models/wallet_tontine.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:http/http.dart';

import '../../constants/server.dart';
import '../../models/session.dart';

class walletTontine extends StatefulWidget {
  final Tontine tontine;
  final Session listsession;
  final String numeroTour;
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
          _dialogShown=false;
        });
      }
    });
  }
  WalletTontine? wallet;
  List<Transactions>_listeTransac=[];
  bool _ouvert=true;
  bool _monTour=false;
  late bool _dialogShown;
  bool _pasJourprevu=false;
  bool _masque=true;
  late String infoTour;

  bool optionAffiche=false;

  
  //Recupérer le wallet
  Future<void>recupererWallet() async{
    final url=Uri.parse("${adress}?ressource=tontines&action=wallet_infos");
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
    final url=Uri.parse("${adress}?ressource=tontines&action=transactions");
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
    final url=Uri.parse("${adress}?ressource=participants&action=verifierTour");
    final response=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
        "code_tontine":widget.tontine.code_tontine
        }));
    if(response.statusCode==200){
      final Map<String,dynamic>donnee=jsonDecode(response.body);
      if(donnee['success']==true){
        var tour=donnee['data'];
        if(widget.listsession.code_participant==tour['code_participant'] && int.parse(widget.numeroTour)==tour['ordre']){
          //Récupérer la date du jour
          String today = DateTime.now().toString();
          String dateJour=today.split(" ")[0];
          //Récupérer la date prévu
          String datePrevu=tour['date_tour'].split(" ")[0];
          if(dateJour==datePrevu){
            setState(() {
              _monTour=true;
            });
          }else{
            setState(() {
              _pasJourprevu=true;
            });
          }
        }
      }
    }
}

Future<bool>retirer()async{
    final url=Uri.parse("${adress}?ressource=tontines&action=retirer");
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
          setState(() {
            widget.tontine.etat=cheque['statut_tontine'];
          });
          return true;
        }
      }else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Désolé"),),
            content: Text(donnee['message']),
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
      print(response.statusCode);
    }
    return false;
}

Future<bool>relancer()async{
    final url=Uri.parse("${adress}?ressource=tontines&action=liste_tours");
    final response=await post(url,headers: {'content-Type':'application/json'},body: jsonEncode([
      {
        'code_tontine':widget.listsession.code_tontine,
        'relancer':'Oui'
      }
    ]));
    if(response.statusCode==200){
      final donnee=jsonDecode(response.body) as Map<String,dynamic>;
      if(donnee['success']){
        setState(() {
          infoTour=donnee['message'];
        });
        return true;
      }
    }else{
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Text("Attention"),
          content: Text("Une erreur serveur s'est produite, veuillez reéssayer plus tard. Merci"),
          actions: [
            TextButton.icon(onPressed: (){
              Navigator.of(context).pop();
            }, label: Text("Compris"),icon: Icon(Icons.verified,color: Colors.green,),)
          ],
        );
      });
    }
    return false;
}




  @override
  Widget build(BuildContext context) {
    if(wallet==null){
      return Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      if(_dialogShown==false && widget.tontine.etat=="En attente"){
        Center(
          child: await showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text("Oups !"),
              content: Text("En attente des autres participants. Veuillez patienter svp.",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,),
              actions: [
                TextButton.icon(onPressed: (){
                  setState(() {
                    _dialogShown = true; // empêcher les doublons
                  });
                  Navigator.of(context).pop();
                }, label: Text("Compris"),icon: Icon(Icons.verified,color: Colors.green,),)
              ],
            );
          }),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Compte de tontine",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: recupererWallet,
        child: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Column(
            children: [
              SizedBox(
                height: 230.h,
                child: Card(
                  color: Color( 0xFF2596be),//couleur.primaryPurple,
                  child: Padding(
                    padding: EdgeInsets.all(10.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Montant en caisse",style: TextStyle(
                                  fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                _masque?
                                  Text("*********",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w900
                                  ),)
                                  :TweenAnimationBuilder(tween: Tween(begin: 0,end: double.parse(wallet!.solde_tontine.toString())), duration: Duration(seconds: 2), builder: (context,value,child){
                                  return Text(
                                      "${value.toStringAsFixed(2)} FCFA",style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ));
                                }),
                                SizedBox(
                                  width: 10.w,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _masque=!_masque;
                                    });
                                  },
                                  child: Icon(_masque? Icons.visibility:Icons.visibility_off,color: Colors.white,),
                                )
                              ],
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Center(
                                    child: TextButton.icon(onPressed: () async {
                                      if(_monTour){
                                        if(await retirer()){
                                          showDialog(context: context, builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Center(child: Text("Félicitation"),),
                                              content: Text("Retrait éffectué avec succès !",style: TextStyle(
                                                fontSize: 14.sp
                                              ),),
                                              actions: [
                                                TextButton.icon(onPressed: (){
                                                  if(widget.tontine.etat=="Terminée"){
                                                    if(widget.listsession.type_participant=="Organisateur" && optionAffiche==false){
                                                      setState(() {
                                                        optionAffiche=true;
                                                      });
                                                      if(optionAffiche){
                                                        showDialog(context: context, builder: (BuildContext context){
                                                          return AlertDialog(
                                                            title: Text("Encore une tontine qui fini sans palabre",style: TextStyle(
                                                                fontSize: 14.sp
                                                            ),),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text("Que voulez vous faire ?",style: TextStyle(
                                                                    fontSize: 14.sp
                                                                ),),
                                                                SizedBox(
                                                                  height: 12.h,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                  children: [
                                                                    TextButton.icon(onPressed: () async{
                                                                      Navigator.of(context).popUntil((route)=>route.isFirst);//Pour fermer les dialogues
                                                                      //Appeler fonction pour générer les nouveaux tours
                                                                      if(await relancer()){
                                                                        if(widget.listsession.type_participant!="Organisateur"){
                                                                          showDialog(context: context, builder: (BuildContext context){
                                                                            return AlertDialog(
                                                                              title: Text("Attention !"),
                                                                              content: Text("L'organisateur a décidé de lancer un nouveau cycle. Veuillez vous reconnecter pour actualiser les tours. Merci",style: TextStyle(
                                                                                fontSize: 12.sp,
                                                                              ),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,),
                                                                              actions: [
                                                                                TextButton.icon(onPressed: (){
                                                                                  Navigator.of(context).popUntil((route)=>route.isFirst);
                                                                                }, label: Text("Compris !"),icon: Icon(Icons.verified,color: Colors.green,),),
                                                                              ],
                                                                            );
                                                                          });
                                                                        }else{
                                                                          Navigator.of(context).popUntil((route)=>route.isFirst);//Pour fermer les dialogues
                                                                          Navigator.of(context).popUntil((route)=>route.isFirst);
                                                                          showDialog(context: context, builder: (BuildContext context){
                                                                            return AlertDialog(
                                                                              title: Text("Avertissement"),
                                                                              content: Text("Vous serrez deconnecté automatiquement pour actualiser les tours. Merci"),
                                                                              actions: [
                                                                                TextButton.icon(onPressed: (){
                                                                                  Navigator.of(context).pop();
                                                                                }, label: Text("Compris"),icon: Icon(Icons.verified,color: Colors.green,),)
                                                                              ],
                                                                            );
                                                                          });
                                                                        }
                                                                      }
                                                                    }, label: Text("Nouveau cycle",style: TextStyle(
                                                                        fontSize: 14.sp
                                                                    ),),icon: Icon(Icons.fiber_new_rounded,color: Colors.green,),),
                                                                    TextButton.icon(onPressed: (){
                                                                      //Fonction pour cloturer la tontine
                                                                    }, label: Text("Cloturer",style: TextStyle(
                                                                        fontSize: 14.sp
                                                                    ),),icon: Icon(Icons.close_rounded,color: Colors.red,),),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    }else{
                                                      showDialog(
                                                          barrierDismissible: false,
                                                          context: context, builder: (BuildContext context){
                                                        return AlertDialog(
                                                          backgroundColor: Colors.white,
                                                          elevation: 0,
                                                          content: Center(
                                                            child: CircularProgressIndicator(),
                                                          ),
                                                        );
                                                      });
                                                    }
                                                  }else{
                                                    Navigator.of(context).pop();
                                                  }
                                                }, label: Text("Merci !"),icon: Icon(Icons.verified,color: Colors.lightGreen,),)
                                              ],
                                            );
                                          });
                                        }
                                      }else if(widget.numeroTour=="N/A"){
                                        showDialog(context: context, builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Center(child: Text("Désolé"),),
                                            content: Text("Mon vieux, tout le monde n'est pas encore arrivé 😅."),
                                            actions: [
                                              Center(child: TextButton.icon(onPressed: (){
                                                Navigator.of(context).pop();
                                              }, label: Text("Compris !"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
                                            ],
                                          );
                                        });
                                      } else{
                                        showDialog(context: context, builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Center(child: Text("Désolé"),),
                                            content: Text(_pasJourprevu?"Djo c'est ton tour, mais faut attendre la date. S'il te plaît 🙏🏾":"Mon vieux, tu es N°${widget.numeroTour}, faut pas presser le chauffeur 😅."),
                                            actions: [
                                              Center(child: TextButton.icon(onPressed: (){
                                                Navigator.of(context).pop();
                                              }, label: Text("Compris !"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
                                            ],
                                          );
                                        });
                                      }
                                    }, label: Text("Retrait",style: TextStyle(
                                      color: Colors.black
                                    ),),icon: Icon(Icons.arrow_downward,color: Colors.black,),style: TextButton.styleFrom(
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
                              height: 30.h,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0.w),
                              child: Icon(_ouvert?Icons.lock_open:Icons.lock_outline,size: 80.r,color: _ouvert? Colors.red:Colors.white,),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Divider(
                height: 5.h,
                color: Colors.grey[400],
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows,size: 25.r,),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text("Historique des transactions",style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              SizedBox(
                  height:435.h,
                  width: double.maxFinite,
                  child: ListView.builder(
                  itemCount: _listeTransac.length,
                  itemBuilder: (context,index){
                    final Transactions transac=_listeTransac[index];
                return GestureDetector(
                  onTap: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        title: Center(child: Text("Détails de transaction",style: TextStyle(
                            fontSize: 15.sp
                        ),)),
                        content: SizedBox(
                          height: 220.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nom :${transac.nom}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Prénoms :${transac.prenoms}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Type de transaction :${transac.type_transaction}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Montant de transaction :${transac.montant_transaction}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Date de transaction :${transac.date_transaction}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Mode de paiement :${transac.mode_paiement}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text("Statut: ${transac.statut_paiement}",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
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
                      fontSize: 16.sp,
                        fontWeight: FontWeight.bold
                    ),),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transac.type_transaction,style: TextStyle(
                              fontSize: 14.sp
                            ),),
                            Text(transac.date_transaction,style: TextStyle(
                                fontSize: 14.sp
                            ),)
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
                              width: 10.h,
                            ),
                            Column(
                              children: [
                                Icon(transac.type_transaction!="Retrait"? Icons.arrow_outward:Icons.arrow_downward,color:transac.type_transaction!="Retrait"? Colors.green:Colors.red,size: 20.r)
                              ],
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                );}))
            ],
          ),
        ),
      ),
    );
  }
}
