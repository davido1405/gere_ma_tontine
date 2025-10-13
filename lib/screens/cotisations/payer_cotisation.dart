import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/cotisation.dart';
import 'package:gerematontine/models/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/colors.dart';
import '../../constants/server.dart';
import 'package:path_provider/path_provider.dart'; // Pour getApplicationDocumentsDirectory()


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



  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;
  bool enCourtraitement=false;
  String lottieAffiche='';


  List<Cotisation>_listCotisation=[];

  String _selectedOption ="";

  TextEditingController montant=TextEditingController();
  TextEditingController montantFraisinculs=TextEditingController();
  final ScreenshotController _screenshotController=ScreenshotController();

  //late bool paye;

  Future<void>fetchCotisation() async{
    String? jwt=await widget.listsession.getSecureJwt();
    final url=Uri.parse("${adress}?ressource=cotisations&action=voir_mes_cotisations");
    final response = await http.post(url,headers: {'content-Type':'application/json',
      "Authorization":"Bearer $jwt"},body: convert.jsonEncode({
      "code_participant":widget.listsession.code_participant,
      "code_tontine":widget.listsession.code_tontine
    }));
    if(response.statusCode==200){
      final Map <String,dynamic> data =convert.jsonDecode(response.body);
      List<dynamic>coti=data['data']??[];
      setState(() {
        _listCotisation=coti.map((coti)=>Cotisation.fromJson(coti)).toList();
      });
    }
  }

  Future<void> payerCotisation(String x, String y) async {
    String? jwt = await widget.listsession.getSecureJwt();
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
                  const Text("Paiement en cours...")
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final url = Uri.parse("${adress}?ressource=cotisations&action=payer_cotisation");
      final reponse = await http.post(
        url,
        headers: {
          "content-Type": "application/json",
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode({
          "code_tontine": widget.listsession.code_tontine,
          "code_participant": widget.listsession.code_participant,
          "montant": int.tryParse(x) ?? 0,
          "libelle_mode_paiement": y
        }),
      );

      // 2️⃣ Fermer le dialogue de chargement une fois la réponse obtenue
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (reponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(reponse.body);
        bool success = data['success'];

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
                    data['message'],
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
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                      montant.clear();
                      montantFraisinculs.clear();
                      fetchCotisation();
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
      } else {
        setState(() => enCourtraitement = false);
        print("Erreur serveur : ${reponse.statusCode}");
      }
    } catch (e) {
      // 2bis️⃣ Fermer le dialogue de chargement si une erreur se produit
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
              onPressed: () => Navigator.pop(context),style: TextButton.styleFrom(
              backgroundColor: Couleur.secondaryGreen
            ),
              child: const Text("Compris",style: TextStyle(
                color: Colors.white
              ),),
            )
          ],
        ),
      );
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
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
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
                    double total= somme*(1+0.02);
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
                    double total2=somme2/(1+0.02);

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
                Text("Frais total de transaction 2%(1% Djarra + 1% opérateurs)",style: TextStyle(
                  fontSize: 14.sp,
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
                                        Text("Mode de paiement",style: TextStyle(
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
                                          height: 20.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                                          child: ElevatedButton.icon(onPressed: enCourtraitement? null: (){
                                            String montantPaiement=montantFraisinculs.text;
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
                                                      children: [Icon(Icons.error_outline,color: Colors.white,size: 30.r,),SizedBox(width: 8.w,),Expanded(
                                                        child: Text("Veuillez remplir tout les champs !",style: TextStyle(
                                                        color: Colors.white),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                      )],),
                                                color: Colors.red.shade700,);
                                              },).show(context);
                                            }else{
                                              print(montantPaiement);
                                              print(montant.text);
                                              payerCotisation(montantPaiement, modePaie);
                                            }
                                          },style: TextButton.styleFrom(
                                              backgroundColor: Couleur.secondaryGreen
                                          ), label:enCourtraitement?Text("Paiement en cours...",style: TextStyle(
                                            color: Colors.white
                                          ),):Text("Payer",style: TextStyle(
                                              color: Colors.white
                                          ),),icon:enCourtraitement?SizedBox(width:20.w,height:20.h,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)):Icon(Icons.monetization_on,color: Colors.white,),),
                                        )
                                      ]),
                                ),
                              );}
                            );
                          });}, label: Text("Valider le paiement",style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),),style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primaryBlue,
                    ),))
                  ],
                ),
              SizedBox(
                height: 5.h,
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
                height: 5.h,
              ),
              SizedBox(
                height: 400.h,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                        child: _listCotisation.isEmpty ?
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
                            itemCount: _listCotisation.length,
                            itemBuilder: (context,index){
                              final Cotisation cotisa=_listCotisation[index];
                              return GestureDetector(
                                onTap: (){
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true, // Add this to allow custom height
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setModalState) {
                                          return DraggableScrollableSheet(
                                            initialChildSize: 0.70, // 90% of screen height
                                            minChildSize: 0.5,
                                            //maxChildSize: 0.95,
                                            expand: false,
                                            builder: (context, scrollController) {
                                              return Column(
                                                children: [
                                                  // Scrollable content
                                                  Expanded(
                                                    child: SingleChildScrollView(
                                                      controller: scrollController,
                                                      child: Screenshot(
                                                        controller: _screenshotController,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: Couleur.lightGray,
                                                            borderRadius: BorderRadius.circular(12.r),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8.0.w),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Center(
                                                                  child: Image.asset(
                                                                    "assets/Djarra Finances V1.png",
                                                                    width: 80.w,
                                                                    height: 80.h,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 10.h),
                                                                Center(
                                                                  child: Text(
                                                                    "Reçu de Transaction",
                                                                    style: TextStyle(
                                                                      fontSize: 20.sp,
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.all(6.0.w),
                                                                  child: Text("Aperçu"),
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(12.r),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(6.0.w),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Type",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: FittedBox(
                                                                                fit: BoxFit.scaleDown,
                                                                                child: Text(
                                                                                  "Paiement de cotisation",
                                                                                  style: TextStyle(fontSize: 15.sp),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Code",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                cotisa.code_cotisation,
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Opérateur ",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                cotisa.mode_paiement,
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Participant ",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                "${widget.listsession.nom_participant} ${widget.listsession.prenoms_participant}",
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Montant ",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                "${cotisa.montant} FCFA",
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Nombre de tour avancé ",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                cotisa.tour_avance,
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 5.h),
                                                                Padding(
                                                                  padding: EdgeInsets.all(6.0.w),
                                                                  child: Text("Détails"),
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(12.r),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(6.0.w),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Statut",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: FittedBox(
                                                                                fit: BoxFit.scaleDown,
                                                                                child: Text(cotisa.statut_paiement),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Frais",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                "${(double.tryParse(cotisa.montant) ?? 0) * 1.02 - (double.tryParse(cotisa.montant) ?? 0)} FCFA",
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: Text(
                                                                                "Date et heure ",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.sp,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Text(
                                                                                cotisa.date_paiement,
                                                                                style: TextStyle(fontSize: 15.sp),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 50.h,),
                                                                Center(child: Text("En partenariat avec EcoBank")),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Fixed button at bottom
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0.w),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: TextButton.icon(
                                                        onPressed: () async {
                                                          final Uint8List? image = await _screenshotController.capture();
                                                          if (image != null) {
                                                            final directory = await getApplicationDocumentsDirectory();
                                                            final file = File('${directory.path}/recu_${widget.listsession.nom_participant}_${cotisa.date_paiement}.png');
                                                            await file.writeAsBytes(image);
                                                            await Share.shareXFiles([XFile(file.path)], text: 'Réçu du paiement');
                                                          }
                                                        },
                                                        label: Text(
                                                          "Partager le reçu",
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        icon: Icon(Icons.ios_share_rounded, color: Colors.white),
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Couleur.secondaryGreen,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
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
                                    Text("Montant: ${cotisa.montant} FCFA",style: TextStyle(
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
