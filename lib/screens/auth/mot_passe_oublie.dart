
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/screens/auth/confirmation_numero.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mot_passe_oublie extends StatefulWidget {
  const mot_passe_oublie({super.key});

  @override
  State<mot_passe_oublie> createState() => _mot_passe_oublieState();
}

class _mot_passe_oublieState extends State<mot_passe_oublie> {
  TextEditingController numero=TextEditingController();
  String? bonNumero;

  Future<void>initSharedPreference()async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      bonNumero=prefs.getString("mobile");
      print(bonNumero);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Code secret oublié",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:  20.w),
          child: Container(
            child: Padding(padding: EdgeInsets.only(top: 35.h),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                TextField(
                  controller: numero,
                  decoration: InputDecoration(
                    label: Text("Numéro de téléphone",style: TextStyle(
                        fontSize: 16.sp
                    ),),
                    filled: true,
                    fillColor: couleur.lightGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: couleur.lightGray)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: couleur.secondaryText)
                    ),
                  )
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left:20.w,right: 20.w),
                  child: Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: ()async{
                        SharedPreferences prefs=await SharedPreferences.getInstance();
                        setState(() {
                          bonNumero=prefs.getString('mobile');
                        });
                        if(numero.text.isNotEmpty){
                          //Nettoyer le numéro stocké et saisi
                          String stocker=bonNumero!.replaceAll(' ', '');
                          String nouveau=numero.text.replaceAll(' ', '');
                          
                          //Expression regulière pour séparer indicatif et numero
                          final regex= RegExp(r'^(\+\d{1,4})(\d+)$');
                          final match=regex.firstMatch(stocker);
                          if(match !=null){
                            String numeroSansindi=match.group(2)!;
                            if(numeroSansindi==nouveau || stocker==nouveau){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const ConfirmationNumero()));
                            }else{
                              showDialog(context: context, builder: (BuildContext context){
                                return AlertDialog(
                                  title: Center(child: Text("Erreur")),
                                  content: Text("Veuillez renseigner le bon numéro"),
                                  actions: [
                                    Center(child: TextButton.icon(onPressed: (){
                                      Navigator.of(context).pop();
                                    }, label: Text("Compris"),icon: Icon(Icons.verified,color:Colors.green),),)
                                  ],
                                );
                              });
                            }
                          }
                        }else{
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              title: Center(child: Text("Erreur")),
                              content: Text("Ce champ ne peut-être laissé vide !"),
                              actions: [
                                Center(child: TextButton.icon(onPressed: (){
                                  Navigator.of(context).pop();
                                }, label: Text("Compris"),icon: Icon(Icons.verified,color:Colors.green),),)
                              ],
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleur.primaryPurple
                      ), child: Text("Suivant",style: TextStyle(
                        color: Colors.white
                      ),),))
                    ],
                  ),
                )
              ],
            ),)
          ),
        ))
    );
  }
}
