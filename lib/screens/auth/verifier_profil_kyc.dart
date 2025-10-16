import 'dart:convert';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/colors.dart';

class verifier_profil_kyc extends StatefulWidget {
  final Session listsession;
  const verifier_profil_kyc({super.key, required this.listsession});

  @override
  State<verifier_profil_kyc> createState() => _verifier_profil_kycState();
}



class _verifier_profil_kycState extends State<verifier_profil_kyc> {
  List<String>typeDocuments=[
    "CNI",
    "Passeport",
    "Permis"
  ];
  String? _typeChoisi;
  int _etape=0;
  TextEditingController numeroDocument=TextEditingController();

  bool imageRecto=false;
  File? imageRectoPath;
  File? imageVersoPath;
  File? imageSelfiePath;
  //late File chemin;



  //Déclancher la camera
  Future<File?>ouvrirCamera()async {
    File? chemin;
    //Demander la permission
    var statutPermission=await Permission.camera.request();
    if(statutPermission.isGranted){
      final ImagePicker choi=ImagePicker();
      final XFile? imageDoc=await choi.pickImage(source: ImageSource.camera);
      if(imageDoc!=null){
        chemin=File(imageDoc.path);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission caméra refusée"))
      );
    }
    return chemin;
  }

  Future<void> envoyerDemande() async {
    String? jwt = await widget.listsession.getSecureJwt();

    if (_typeChoisi == null || numeroDocument.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Statut"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/animations/Checking Phone.json",
                width: 150.w, height: 150.h),
            SizedBox(height: 10.h),
            Text("Envoi de la demande..."),
          ],
        ),
      ),
    );

    try {
      final uri = Uri.parse("${adress}?ressource=participants&action=demande_upgrade_kyc");

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $jwt'
        ..fields['code_participant'] = widget.listsession.code_participant
        ..fields['type_document'] = _typeChoisi!
        ..fields['numero_document'] = numeroDocument.text;

      // 🔹 Ajout des fichiers selon le type de document
      if (imageRectoPath!.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'fichier_document_recto',
          imageRectoPath!.path,
        ));
      }

      if (_typeChoisi != "Passeport" && imageVersoPath!.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'fichier_document_verso',
          imageVersoPath!.path,
        ));
      }

      if (imageSelfiePath!.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'selfie_photo',
          imageSelfiePath!.path,
        ));
      }

      // 🔹 Envoi de la requête
      var response = await request.send();

      // Fermer le dialogue de chargement
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();

        print(body);
        var data = jsonDecode(body);
        bool statutReq = data['success'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Statut"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  statutReq
                      ? "assets/animations/Approve.json"
                      : "assets/animations/Sign for error _ Flat style.json",
                  width: 150.w,
                  height: 150.h,
                ),
                Center(child: Text(data['message'])),
              ],
            ),
            actions: [
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(seconds: 2), () {Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => connexion_screen()),(route) => false,);});
                  },
                  icon: const Icon(Icons.verified, color: Colors.white),
                  label: const Text("Compris", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Couleur.secondaryGreen,
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Oups! Une erreur s'est produite veuillez réessayer plus tard. Merci !)")),
        );
      }
    } catch (e) {
      //Navigator.of(context).pop();
      //ScaffoldMessenger.of(context).showSnackBar(
        //SnackBar(content: Text("Erreur : $e")),
      //);
      print("$e");
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vérifier mon profil KYC"),
      ),
      body: SafeArea(child: Column(
        children: [
          Expanded(
            child: Stepper(steps: [
              Step(
                isActive: _etape==0,
                  title: Text("Documents", style: TextStyle(fontSize: 12.sp)), content: _infoDoc()),
              Step(
                isActive: _etape==1,
                  title: Text("Scan documents", style: TextStyle(fontSize: 12.sp)), content: _photoDoc()),
              Step(
                  isActive: _etape==2,
                  title: Text("Selfie", style: TextStyle(fontSize: 12.sp)), content: _photoSelfie())
            ],type: StepperType.horizontal,
              onStepTapped: (int _nouvelleEtape){
              setState(() {
                _etape=_nouvelleEtape;
              });
            },currentStep: _etape,
            onStepContinue: (){
              if(_etape!=2){
                setState(() {
                  _etape+=1;
                });
              }else{
                envoyerDemande();
              }
            },onStepCancel: (){
              if(_etape!=0){
                setState(() {
                  _etape-=1;
                });
              }
              },),

          ),
        ],
      )
      ),
    );
  }

  Widget _infoDoc() {
    return Card(
      elevation: 2,
      color: Couleur.lightGray,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informations sur document"),
            SizedBox(height: 15.h,),
            DropdownButtonFormField<String>(
                decoration: InputDecoration(
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
                hint:Text("Sélectionner le type de documents",style: TextStyle(
                    fontSize: 16.sp
                ),),
                value: _typeChoisi,
                items: typeDocuments.map<DropdownMenuItem<String>>((String value){
              return DropdownMenuItem<String>(value: value,child:Text(value),);
            }).toList(), onChanged: (String? _nouvelleValeur){
              setState(() {
                _typeChoisi=_nouvelleValeur;
              });
            }),
            SizedBox(height: 10.h,),
            Row(
              children: [
                Text("Numéro du document"),
                SizedBox(width: 2.w,),
                Text("*",style: TextStyle(
                  color: Colors.red
                ),),
              ],
            ),
            SizedBox(height: 5.h,),
            //Numéro du document
            TextField(
              controller: numeroDocument,
              decoration: InputDecoration(
                  hint: Text('Ex: CI12345678',style: TextStyle(
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
            Row(
              children: [
              Expanded(
                flex: 3,
                  child: Text("Veuillez saisir le numéro tel que inscrit sur le document")),
              Expanded(
                flex: 1,
                child: Text("*",style: TextStyle(
                    color: Colors.red
                ),),
              ),],)
          ],
        ),
      ),
    );
  }

  Widget _photoDoc() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Photo recto"),
            SizedBox(width: 5.w,),
            Text("*",style: TextStyle(color: Colors.red),),
          ],
        ),
        Card(
          elevation: 2,
          color: Couleur.lightGray,
          child: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h,),
                GestureDetector(
                  onTap: () async {
                    final result = await ouvrirCamera();
                    if(result != null) {
                      setState(() {
                        imageRectoPath = result;
                      });
                    }

                  },
                  child: ClipRRect(
                    child: imageRectoPath!=null?Container(height:200.h,width:double.infinity,child: Image.file(imageRectoPath!,fit: BoxFit.contain,)):Center(child: Column(
                      children: [
                        Icon(Icons.badge_outlined,color:Colors.grey,size: 130.r,),
                        FittedBox(child: Text("Touchez l'icon pour charger une photo du document(Recto)",style: TextStyle(color: Colors.blueAccent),))
                      ],
                    ),),
                  ),
                ),
              ],
            ),
          ),
        ),
        if((_typeChoisi=="CNI")||(_typeChoisi=="Permis"))
          Row(
            children: [
              Text("Photo verso"),
              SizedBox(width: 5.w,),
              Text("*",style: TextStyle(color: Colors.red),),
            ],
          ),
        if((_typeChoisi=="CNI")||(_typeChoisi=="Permis"))
          Card(
            elevation: 2,
            color: Couleur.lightGray,
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await ouvrirCamera();
                      if(result != null) {
                        setState(() {
                          imageVersoPath = result;
                        });
                      }
                    },
                    child: ClipRRect(
                      child: imageVersoPath!=null?Container(height:200.h,width:double.infinity,child: Image.file(imageVersoPath!,fit: BoxFit.contain,)):Center(child: Column(
                        children: [
                          Icon(Icons.featured_play_list_rounded,size: 130.r,color: Colors.grey,),
                          FittedBox(child: Text("Touchez l'icon pour charger une photo du document(Verso)",style: TextStyle(color: Colors.blueAccent),))
                        ],
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _photoSelfie() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Row(
            children: [
              Text("Photo selfie"),
              SizedBox(width: 5.w,),
              Text("*",style: TextStyle(color: Colors.red),),
            ],
          ),
        ),
        Card(
          elevation: 2,
          color: Couleur.lightGray,
          child: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h,),
                GestureDetector(
                  onTap: () async {
                    final result = await ouvrirCamera();
                    if(result != null) {
                      setState(() {
                        imageSelfiePath = result;
                      });
                    }
                  },
                  child: ClipRRect(
                    child: imageSelfiePath!=null?Container(height:200.h,width:double.infinity,child: Image.file(imageSelfiePath!,fit: BoxFit.contain,)):Center(child: Column(
                      children: [
                        Icon(Icons.face,color:Colors.grey,size: 130.r,),
                        FittedBox(child: Text("Touchez l'icon pour prendre une photo selfie de vous(Choisi un endroit bien éclairé SVP)",style: TextStyle(color: Colors.blueAccent),))
                      ],
                    ),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
