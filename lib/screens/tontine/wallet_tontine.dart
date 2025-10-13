import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/tontines.dart';
import 'package:gerematontine/models/transactions.dart';
import 'package:gerematontine/models/wallet_tontine.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

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

class _walletTontineState extends State<walletTontine> with SingleTickerProviderStateMixin{

  //Initialisation de toutes mes fonction
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dialogShown=false;
    recupererWallet();
    transacs();
    verifierTour();
    _controllerAnimation=AnimationController(duration: Duration(seconds: 2),vsync: this);
    Future.delayed(Duration(seconds: 2),(){
      if(mounted){
        setState(() {
          _ouvert=false;
        });
      }
    });
  }
  late AnimationController _controllerAnimation;
  WalletTontine? wallet;
  List<Transactions>_listeTransac=[];
  bool _ouvert=true;
  bool _monTour=false;
  bool _dialogShown=false;
  bool _pasJourprevu=false;
  bool _masque=true;
  bool optionAffiche=false;
  String _selectedOption ="";
  bool enCourtraitement=false;


  //Recupérer le wallet
  Future<void>recupererWallet() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=wallet_infos");
    final reponse=await post(url,headers: {'Authorization':'Bearer $jwt','content-Type':'application/json'},body: jsonEncode(
        {
          "code_tontine":widget.listsession.code_tontine
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
  String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=tontines&action=transactions");
    final response=await post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
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
        }else{
          setState(() {
            _listeTransac=[];
          });
        }
      }
    }
}

Future<void>verifierTour()async{
  String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participants&action=verifierTour");
    final response=await post(url,headers: {"content-Type":"application/json",
      "Authorization":"Bearer $jwt"},body: jsonEncode(
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
  String? jwt=await widget.listsession.getSecureJwt();
  setState(() {
    enCourtraitement = true;
  });

  // 1️⃣ Affiche le dialogue de chargement
  showDialog(
    context: context,
    barrierDismissible: false, // empêche de fermer en cliquant dehors
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text("Statut")),
        content: SizedBox(
          height: 200.h,
          child: Center(
            child: Column(
              children: [
                Lottie.asset("assets/animations/Card swiping.json", width: 150.w, height: 150.h),
                const SizedBox(height: 10),
                const Text("Retrait en cours...")
              ],
            ),
          ),
        ),
      );
    },
  );

    try{
      final url=Uri.parse("${adress}?ressource=tontines&action=retirer");
      final response=await post(url,headers: {"content-Type":"application/json",
        "Authorization":"Bearer $jwt"},body: jsonEncode(
          {
            "code_tontine":widget.listsession.code_tontine,
            "code_participant":widget.listsession.code_participant
          }));

      // 2️⃣ Fermer le dialogue de chargement une fois la réponse obtenue
      if (Navigator.canPop(context)) Navigator.pop(context);

      if(response.statusCode==200){
        final Map<String,dynamic>donnee=jsonDecode(response.body);
        bool success=donnee['success']==true;
        // 3️⃣ Affiche le résultat (succès ou erreur)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Statut paiement",
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  success
                      ? Lottie.asset(
                    'assets/animations/Approve.json',
                    width: 150.w,
                    height: 150.h,
                  )
                      : Lottie.asset(
                    'assets/animations/Sign for error _ Flat style.json',
                    width: 150.w,
                    height: 150.h,
                  ),
                  Text(
                    donnee['message'],
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        enCourtraitement = false;
                        _selectedOption = "";
                      });
                      var cheque=donnee['data'];
                      print(cheque);
                      if(cheque != null && cheque is Map && cheque.containsKey('statut_tontine')){
                        setState(() {
                          widget.tontine.etat=cheque['statut_tontine'];
                        });
                        recupererWallet();
                      }
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Couleur.secondaryGreen,
                    ),
                    icon: const Icon(Icons.verified, color: Colors.white),
                    label: Text(
                      "Compris",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        );
      }else{
        setState(() {
          enCourtraitement=false;
        });
        return false;
      }
    }catch(e){
      Navigator.of(context).pop();
      setState(() => enCourtraitement = false);

      // 3bis️⃣ Affiche un dialogue d’erreur
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erreur"),
          content: Text("Une erreur est survenue : $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Compris"),
            )
          ],
        ),
      );
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
              ClipRRect(
                child: Card(
                  color: Couleur.primaryBlue,//couleur.primaryPurple,
                  child: Padding(
                    padding: EdgeInsets.all(10.0.w),
                    child: // Remplacez tout le Row principal (ligne 259 à ~423) par ce code :
                    Row(
                      children: [
                        // Utilisez Expanded pour la colonne principale
                        Expanded(
                          flex: 6, // 60% de l'espace disponible
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.h),
                              Text(
                                "Montant en caisse",
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // Le Row problématique - maintenant avec des contraintes appropriées
                              Row(
                                children: [
                                  // Flexible pour le texte/animation du montant
                                  Flexible(
                                    child: _masque
                                        ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "*********",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w900
                                        ),
                                      ),
                                    )
                                        : TweenAnimationBuilder(
                                        tween: Tween(begin: 0, end: double.parse(wallet!.solde_tontine.toString())),
                                        duration: Duration(seconds: 2),
                                        builder: (context, value, child) {
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                "${value.toStringAsFixed(2)} FCFA",
                                                style: TextStyle(
                                                    fontSize: 25.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white
                                                )
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  // Icône de visibilité - pas de Flexible pour garder sa taille
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _masque = !_masque;
                                      });
                                    },
                                    child: Icon(
                                      _masque ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Center(
                                child: Row(
                                  children: [
                                    Center(
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          // Votre logique existante pour le bouton retrait
                                          if(_monTour){
                                            //Afficher le modal pour le mode de retrait
                                            showModalBottomSheet(
                                                backgroundColor: Colors.grey[300],
                                                elevation: 3,
                                                isDismissible: true,
                                                isScrollControlled: true,
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
                                                          constraints: BoxConstraints(
                                                            maxHeight: MediaQuery.of(context).size.height*0.8,
                                                          ),
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 10.h,
                                                                  ),
                                                                  Text("Mode de retrait",style: TextStyle(
                                                                      fontSize: 20.sp,
                                                                      fontWeight: FontWeight.w500
                                                                  ),),SizedBox(
                                                                    height: 10.h,
                                                                  ),
                                                                  Card(
                                                                    elevation: 0,
                                                                    color: Couleur.lightGray,
                                                                    child: InkWell(
                                                                      splashColor: Couleur.primaryBlue.withOpacity(0.2),
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: (){
                                                                        setModalState(() {
                                                                          _selectedOption="Wave";
                                                                        });
                                                                      },
                                                                      child: Padding(
                                                                        padding: EdgeInsets.all(8.0.w),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                                flex:3,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(5.r),
                                                                                      child: Image.asset("assets/wave.png",fit: BoxFit.cover,height: 50.h,
                                                                                        width: 100.w,),
                                                                                    ),
                                                                                    SizedBox(width: 10.w,),
                                                                                    Text("WAVE"),
                                                                                  ],)),
                                                                            Flexible(
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
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2.h,
                                                                  ),
                                                                  Card(
                                                                    elevation: 0,
                                                                    color: Couleur.lightGray,
                                                                    child: InkWell(
                                                                      splashColor: Couleur.primaryBlue.withOpacity(0.2),
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: (){
                                                                        setModalState(() {
                                                                          _selectedOption="Orange Money";
                                                                        });
                                                                      },
                                                                      child: Padding(
                                                                        padding: EdgeInsets.all(8.0.w),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                                flex:3,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(5.r),
                                                                                      child: Image.asset("assets/orange money 2.png",fit: BoxFit.cover,height: 50.h,
                                                                                        width: 100.w,),
                                                                                    ),
                                                                                    SizedBox(width: 10.w,),
                                                                                    Text("Orange"),
                                                                                  ],)),
                                                                            Flexible(
                                                                              flex:1,
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
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5.h,
                                                                  ),
                                                                  Card(
                                                                    elevation: 0,
                                                                    color: Couleur.lightGray,
                                                                    child: InkWell(
                                                                      splashColor: Couleur.primaryBlue.withOpacity(0.2),
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: (){
                                                                        setModalState(() {
                                                                          _selectedOption="MTN Money";
                                                                        });
                                                                      },
                                                                      child: Padding(
                                                                        padding: EdgeInsets.all(8.0.w),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                                flex:3,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(5.r),
                                                                                      child: Image.asset("assets/MTN MONEY.png",fit: BoxFit.cover,height: 50.h,
                                                                                        width: 100.w,),
                                                                                    ),
                                                                                    SizedBox(width: 10.w,),
                                                                                    Text("MTN"),
                                                                                  ],)),
                                                                            Flexible(
                                                                              flex:1,
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
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5.h,
                                                                  ),
                                                                  Card(
                                                                    elevation: 0,
                                                                    color: Couleur.lightGray,
                                                                    child: InkWell(
                                                                      splashColor: Couleur.primaryBlue.withOpacity(0.2),
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: (){
                                                                        setModalState(() {
                                                                          _selectedOption="Moov Money";
                                                                        });
                                                                      },
                                                                      child: Padding(
                                                                        padding: EdgeInsets.all(8.0.w),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                                flex:3,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(10.r),
                                                                                      child: Image.asset("assets/moov.png",fit: BoxFit.cover,height: 50.h,
                                                                                        width: 100.w,),
                                                                                    ),
                                                                                    SizedBox(width: 10.w,),
                                                                                    Text("MOOV"),
                                                                                  ],)),
                                                                            Flexible(
                                                                              flex:1,
                                                                              child: RadioListTile<String>(value: "Moov Money", groupValue: _selectedOption, onChanged: (value){
                                                                                setModalState(() {
                                                                                  _selectedOption=value!;
                                                                                });
                                                                              }),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20.h,
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                                    child: ElevatedButton.icon(onPressed: enCourtraitement? null: (){
                                                                      String modePaie=_selectedOption.toString();
                                                                      retirer();
                                                                    },style: TextButton.styleFrom(
                                                                        backgroundColor: Couleur.secondaryGreen
                                                                    ), label:enCourtraitement?Text("Retrait en cours...",style: TextStyle(
                                                                        color: Colors.white
                                                                    ),):Text("Valider le retirer",style: TextStyle(
                                                                        color: Colors.white
                                                                    ),),icon:enCourtraitement?SizedBox(width:20.w,height:20.h,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)):Icon(Icons.monetization_on,color: Colors.white,),),
                                                                  )
                                                                ]),
                                                          ),
                                                        );}
                                                  );
                                                });
                                          }else if(widget.listsession.numero_participant=="N/A" || widget.tontine.etat=="Terminée"||widget.tontine.etat=="En attente"){
                                            showDialog(context: context, builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Center(child: Text("Désolé"),),
                                                content: Text("Vous ne pouvez pas encore faire de retrait."),
                                                actions: [
                                                  Center(child: TextButton.icon(onPressed: (){
                                                    Navigator.of(context).pop();
                                                  },style: TextButton.styleFrom(
                                                      backgroundColor: Couleur.secondaryGreen
                                                  ), label: Text("Compris",style: TextStyle(color: Colors.white),),icon: Icon(Icons.verified,color: Colors.white,),),)
                                                ],
                                              );
                                            });
                                          } else{
                                            showDialog(context: context, builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Center(child: Text("Désolé"),),
                                                content: Text(_pasJourprevu?"La date de retrait fixée n'est pas encore atteinte":"Vous bénéficiez en position N°${widget.numeroTour}, veuillez donc attendre votre tour."),
                                                actions: [
                                                  Center(child: TextButton.icon(onPressed: (){
                                                    Navigator.of(context).pop();
                                                  },style: TextButton.styleFrom(
                                                      backgroundColor: Couleur.secondaryGreen
                                                  ), label: Text("Compris",style: TextStyle(color: Colors.white),),icon: Icon(Icons.verified,color: Colors.white,),),)
                                                ],
                                              );
                                            });
                                          }
                                        },
                                        label: Text("Retrait", style: TextStyle(color: Colors.white)),
                                        icon: Icon(Icons.arrow_downward, color: Colors.white),
                                        style: TextButton.styleFrom(
                                            backgroundColor: _monTour ? Couleur.secondaryGreen : Couleur.accentOrange
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // Animation Lottie avec un espace contrôlé
                        Expanded(
                          flex: 4, // 40% de l'espace disponible
                          child: Column(
                            children: [
                              Lottie.asset(
                                  'assets/animations/Good investment makes it reach the target.json',
                                  width: 180.w,
                                  height: 180.h
                              ),
                            ],
                          ),
                        )
                      ],
                    )
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
                  child: _listeTransac.isEmpty ?
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    ColorFiltered(colorFilter: ColorFilter.mode(Couleur.primaryBlue, BlendMode.srcATop),
                    child: Lottie.asset("assets/animations/lottieflow-ecommerce-14-7-000000-easey.json",width: 150.w,height: 150.h),),
                        SizedBox(height: 15.h,),
                        Text("Aucune transaction disponible pour le moment")
                      ],
                    ),
                  ): ListView.builder(
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
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
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
                            actions: [
                              Center(
                                child: TextButton.icon(onPressed: (){
                                  Navigator.of(context).pop();
                                },style: TextButton.styleFrom(
                                    backgroundColor: Couleur.secondaryGreen
                                ), label: Text("Compris",style: TextStyle(
                                  color: Colors.white
                                ),),icon: Icon(Icons.verified,color: Colors.white,),),
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
                                    Text(transac.type_transaction!="Retrait" ? "+ ${transac.montant_transaction}":"- ${transac.montant_transaction}",style: TextStyle(
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
                    );
                  })
              )
            ],
          ),
        ),
      ),
    );
  }
}
