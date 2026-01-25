import 'dart:convert';
import 'dart:convert' as convert;

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';
import '../../models/infos_wallet_participant.dart';

class retirer_gains extends StatefulWidget {
  final Session listsession;
  const retirer_gains({super.key, required this.listsession});

  @override
  State<retirer_gains> createState() => _retirer_gainsState();
}

class _retirer_gainsState extends State<retirer_gains> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    infosFinanceParticipant();

  }

  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;
  bool enCourtraitement=false;
  String lottieAffiche='';
  String modePaiement="Choisir mode de paiement";
  bool wallet_parti=true;
  bool payable=false;
  int? cotisationManque;
  String? montantAffiche;
  int? fraisTransac;
  int? totalTransac;

  String _selectedOption ="";


  TextEditingController montant=TextEditingController();

  InfosWallet? infos_wallet_participant;

  //Recupérer le wallet
  Future<void>infosFinanceParticipant() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=participants&action=infos_wallet_participant");
    final response = await post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: convert.jsonEncode({
      "code_participant":widget.listsession.code_participant
    }));
    if(response.statusCode==200){
      Map <String,dynamic> data =convert.jsonDecode(response.body);
      setState(() {
        infos_wallet_participant=InfosWallet.fromJson(data['data']);
      });
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
      final url=Uri.parse("${adress}?ressource=participants&action=retirer");
      final response=await post(url,headers: {"content-Type":"application/json",
        "Authorization":"Bearer $jwt"},body: jsonEncode(
          {
            "code_participant":widget.listsession.code_participant,
            "montant":montant.text,
            "libelle_mode_paiement":modePaiement
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
                    onPressed: () async {
                      if(mounted){
                        setState((){
                          enCourtraitement = false;
                          _selectedOption = "";
                          montant.clear();
                        });
                        await infosFinanceParticipant();
                        Navigator.of(context).pop();
                      }

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Transférer mes gains"),
      ),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: ()async{
          infosFinanceParticipant();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey,
                            width: 0.5.w,
                            style: BorderStyle.solid),
                        bottom: BorderSide(color: Colors.grey,
                            width: 0.5.w,
                            style: BorderStyle.solid),
                        left: BorderSide(color: Colors.grey,
                            width: 0.5.w,
                            style: BorderStyle.solid),
                        right: BorderSide(color: Colors.grey,
                            width: 0.5.w,
                            style: BorderStyle.solid),

                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2,
                        )]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(padding: EdgeInsets.symmetric(horizontal:10.w,vertical: 5.h),child:
                        Text("Solde disponible",style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey
                        ),),),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0.w,),
                            child:Row(
                              children: [
                                Expanded(
                                  child: Text("${infos_wallet_participant?.solde_participant ?? 0} FCFA",style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                  ),),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Padding(padding: EdgeInsets.all(12.w),child: Container(
                decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      bottom: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      left: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),
                      right: BorderSide(color: Colors.grey,
                          width: 0.5.w,
                          style: BorderStyle.solid),

                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2,
                      )]
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.symmetric(horizontal:10.w,vertical: 5.h),child:
                      Text("Montant à transférer",style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey
                      ),),),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0.w,),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: montant,
                          decoration: InputDecoration(
                              suffix: Text("FCFA"),
                              hint: Text("0 FCFA",style: TextStyle(
                                  fontSize: 25.sp,
                                  color: Colors.grey
                              ),)
                          ),
                          style: TextStyle(
                              fontSize: 30.sp,
                              color: Colors.black
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h,),
                      Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    montant.setText("10000");
                                    print("Retrait de ${montant.text}");
                                  },
                                  child: Container(
                                    decoration:BoxDecoration(
                                        color: Couleur.lightGray,
                                        borderRadius: BorderRadius.circular(12.r)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                      child: Text("10k",style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500
                                      ),),
                                    ),),
                                ),
                                GestureDetector(
                                  onTap:(){
                                    montant.setText("15000");
                                    print("Retrait de ${montant.text}");
                                  },
                                  child: Container(
                                    decoration:BoxDecoration(
                                        color: Couleur.lightGray,
                                        borderRadius: BorderRadius.circular(12.r)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                      child: Text("15k",style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500
                                      ),),
                                    ),),
                                ),
                                GestureDetector(
                                  onTap:(){
                                    montant.setText("25000");
                                    print("Retrait de ${montant.text}");
                                  },
                                  child: Container(
                                    decoration:BoxDecoration(
                                        color: Couleur.lightGray,
                                        borderRadius: BorderRadius.circular(12.r)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                      child: Text("25k",style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500
                                      ),),
                                    ),),
                                ),
                                GestureDetector(
                                  onTap:(){
                                    montant.setText("50000");
                                    print("Retrait de ${montant.text}");
                                  },
                                  child: Container(
                                    decoration:BoxDecoration(
                                        color: Couleur.lightGray,
                                        borderRadius: BorderRadius.circular(12.r)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25.0.w,vertical: 10.h),
                                      child: Text("50k",style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500
                                      ),),
                                    ),),
                                ),
                              ],),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                      child: Text("Options de transfert",style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        color: Colors.grey[500]
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
                                    setState(() {
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
                                            Text("WAVE",style: TextStyle(
                                              fontWeight: FontWeight.w500
                                            ),),
                                          ],)),
                                      SizedBox(width: 60.w,),
                                      Expanded(
                                        flex:1,
                                        child: RadioListTile<String>(value: "Wave", groupValue: _selectedOption, onChanged: (value){
                                          setState(() {
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
                                    setState(() {
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
                                            Text("ORANGE",style: TextStyle(
                                                fontWeight: FontWeight.w500
                                            ),),
                                          ],)),
                                      SizedBox(width: 70.w,),
                                      Expanded(
                                        flex: 1,
                                        child: RadioListTile<String>(value: "Orange Money", groupValue: _selectedOption, onChanged: (value){
                                          setState(() {
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
                                    setState(() {
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
                                            Text("MTN",style: TextStyle(
                                                fontWeight: FontWeight.w500
                                            ),),
                                          ],
                                          )
                                      ),
                                      SizedBox(width: 70.w,),
                                      Expanded(
                                        flex: 1,
                                        child: RadioListTile<String>(value: "MTN Money", groupValue: _selectedOption, onChanged: (value){
                                          setState(() {
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
                                  setState(() {
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
                                          Text("MOOV",style: TextStyle(
                                              fontWeight: FontWeight.w500
                                          ),),
                                        ],)),
                                    SizedBox(width: 70.w,),
                                    Expanded(
                                      flex: 1,
                                      child: RadioListTile<String>(value: "Moov Money", groupValue: _selectedOption, onChanged: (value){
                                        setState(() {
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
                    SizedBox(height: 25.h,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: TextButton.icon(onPressed:enCourtraitement?null: (){
                            if(montant.text.isEmpty || modePaiement.isEmpty){
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
                              setState(() {
                                enCourtraitement=true;
                              });
                              retirer();
                            }
                          }, label: Text(enCourtraitement?"Transfert en cours":"Transférer",style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp
                          ),),icon:enCourtraitement?SizedBox(width:25.w,height:25.h,child: CircularProgressIndicator(color: Colors.white,)):Icon(Icons.north_east, color: Colors.white, size: 28.sp),style: TextButton.styleFrom(
                            backgroundColor:enCourtraitement?Couleur.iconInactive:Couleur.secondaryGreen,
                          ),))
                        ],
                      ),
                    )
                  ]),
            ],
          ),
        ),
      )),
    );
  }
}
