import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot/screenshot.dart';

import '../../constants/colors.dart';

class retirer_gains extends StatefulWidget {
  const retirer_gains({super.key});

  @override
  State<retirer_gains> createState() => _retirer_gainsState();
}

class _retirer_gainsState extends State<retirer_gains> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool saisiMontant=false;
  bool saisiMontantFrais=false;
  bool misejourEncour=false;
  bool enCourtraitement=false;
  String lottieAffiche='';
  int? solde_wallet_participant;
  String modePaiement="Choisir mode de paiement";
  bool wallet_parti=true;
  bool payable=false;
  int? cotisationManque;
  String? montantAffiche;
  int? fraisTransac;
  int? totalTransac;

  String _selectedOption ="";


  TextEditingController montant=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Retirer mes gains"),
      ),
      body: SafeArea(child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                                child: Text("125000 FCFA",style: TextStyle(
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
                    Text("Montant à cotiser",style: TextStyle(
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
                    child: Text("Options de retrait",style: TextStyle(
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
                          setState(() {
                            enCourtraitement=true;
                          });
                        }, label: Text(enCourtraitement?"Retrait en cours":"Retirer",style: TextStyle(
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
      )),
    );
  }
}
