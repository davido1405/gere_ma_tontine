import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/supportTech.dart';


class parametre extends StatefulWidget {
  final Session listsession;
  const parametre({super.key, required this.listsession});

  @override
  State<parametre> createState() => _parametreState();
}

class _parametreState extends State<parametre> {

  SupportTech(){
    final String message=Uri.encodeComponent("Bonjour, j'ai besoin d'aide avec GereMaTontine.");
    final String url="https://wa.me/${contact}?text=$message";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
  Color getRandomColor( String input){
    final hash=input.hashCode;
    final couleurs=[Colors.deepOrange,Colors.amber,Colors.cyan,Colors.green,Couleur.primaryBlue,Colors.red,Colors.blue,Couleur.primaryBlue];
    return couleurs[hash % couleurs.length];
  }

  Color choixCouleur(){
    late Color couleurNiveau;
    switch(widget.listsession.niveau_kyc){
      case "KYC1":
        setState(() {
          couleurNiveau=Couleur.primaryBlue;
        });
        break;
      case "KYC2":
        setState(() {
          couleurNiveau=Couleur.accentOrange;
        });
        break;
      case "KYC3":
        setState(() {
          couleurNiveau=Couleur.secondaryGreen;
        });
        break;
    }
    return couleurNiveau;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres",style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
      ),
      body: Padding(padding: EdgeInsets.only(left: 15.w),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Column(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: getRandomColor(widget.listsession.nom_participant),
                child: Text(widget.listsession.nom_participant.substring(0,1).toUpperCase()+widget.listsession.prenoms_participant.substring(0,1).toUpperCase(),style: TextStyle(
                    fontSize: 35.sp,
                    color: Colors.white
                ),),
              ),
              ListTile(
                title: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${widget.listsession.prenoms_participant} ${widget.listsession.nom_participant}",style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold
                      ),),
                      TextButton.icon(onPressed: null,style: TextButton.styleFrom(
                        backgroundColor:choixCouleur()
                      ), label: Text(widget.listsession.niveau_kyc,style: TextStyle(
                        color: Colors.white
                      ),),icon:widget.listsession.niveau_kyc!="KYC1"? Icon(Icons.verified,color:Colors.white):null),
                    ],
                  ),
                ),
              ),
            ],
          ),),
          SizedBox(
            height: 10.h,
          ),
          Text("Informations du compte",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.sp),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.phone_outlined,color: Colors.white,),),
              ),
              Expanded(
                child: ListTile(
                  title: Text("Numéro de téléphone",style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text(widget.listsession.numero_participant),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.shield_outlined,color: Colors.white,),),
              ),
              Expanded(
                child: ListTile(
                  title: Text("Rôle",style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text(widget.listsession.type_participant),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Text("Sécurité",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.sp),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.lock_outline,color: Colors.white,),),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    print("Changer pin");
                  },
                  child: ListTile(
                    title: Text("Changer mon PIN",style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Text("Support technique",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.sp),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.help_outline,color: Colors.white,),),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    print("FAQ");
                  },
                  child: ListTile(
                    title: Text("FAQ",style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Couleur.primaryBlue,//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.support_agent_outlined,color: Colors.white,),),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    SupportTech();
                    print("Nous contacter");
                  },
                  child: ListTile(
                    title: Text("Nous contacter",style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              )
            ],
          ),
        ],
      ),),
    );
  }
}
