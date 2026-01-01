

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/screens/auth/confirmation_numero.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';

class inscription_screen extends StatefulWidget {
  const inscription_screen({super.key});

  @override
  State<inscription_screen> createState() => _inscription_screenState();
}

class _inscription_screenState extends State<inscription_screen> {
  
  TextEditingController nom=TextEditingController();
  TextEditingController prenoms=TextEditingController();
  TextEditingController numero=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    compteDetec();
  }

  @override
  void dispose() {
    nom.dispose();
    prenoms.dispose();
    numero.dispose();
    super.dispose();
  }


  bool? _compteDetecte;
  void compteDetec()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(prefs.getString('nom')!=null){
      setState(() {
        _compteDetecte=true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: _compteDetecte??false,
        title: Center(child: Text("Inscription",style: TextStyle(fontSize:22.sp,fontWeight: FontWeight.bold),),),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(padding: EdgeInsets.only(top: 20.h),
          child: Padding(
            padding: EdgeInsets.only(left: 20.w,right: 20.w),
            child: Column(
              children: [
                Image.asset("assets/Djarra Finances V1.png",width: 150.w,height: 150.h,),
                SizedBox(
                  height: 40.h,
                ),
                TextField(
                  controller: nom,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Nom",style: TextStyle(
                      fontSize: 16.sp
                    ),),
                    filled: true,
                    fillColor: Couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Couleur.lightGray)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Couleur.primaryBlue)
                    )
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextField(
                  controller: prenoms,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Prénoms",style: TextStyle(
                        fontSize: 16.sp
                    ),),
                      filled: true,
                      fillColor: Couleur.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Couleur.lightGray)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Couleur.primaryBlue)
                      )
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextField(
                  controller: numero,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      label:Text("Numéro de téléphone",style: TextStyle(
                          fontSize: 16.sp
                      ),),
                      filled: true,
                      fillColor: Couleur.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Couleur.lightGray)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Couleur.primaryBlue)
                      )
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: () async {
                      if(numero.text.length==10 && nom.text.isNotEmpty && prenoms.text.isNotEmpty){
                        SharedPreferences prefs=await SharedPreferences.getInstance();
                        prefs.setString("nom", nom.text);
                        prefs.setString("prenom", prenoms.text);
                        prefs.setString("mobile", "+225${numero.text}");
                        prefs.setString("identifiant","225${numero.text}");
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ConfirmationNumero()));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
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
                              },).show(context) as SnackBar
                        );
                      }
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primaryBlue,
                    ), label: Text("Suivant",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp
                      ),),))
                  ],
                )
              ],
            ),
          ),),
        ),
      ),
    );
  }
}
