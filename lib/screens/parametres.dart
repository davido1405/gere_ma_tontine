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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Paramètres",style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Padding(padding: EdgeInsets.only(left: 15),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Text("Informations du compte",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color( 0xFF2596be),//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.person_outline,color: Colors.white,),),
              ),
              Expanded(
                child: ListTile(
                  title: Text(widget.listsession.nom_participant+" "+widget.listsession.prenoms_participant,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text(widget.listsession.email_participant),
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
                    borderRadius: BorderRadius.circular(10),
                    color: Color( 0xFF2596be),//couleur.primaryPurple
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
                    borderRadius: BorderRadius.circular(10),
                    color: Color( 0xFF2596be),//couleur.primaryPurple
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
          Text("Préférences",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color( 0xFF2596be),//couleur.primaryPurple
                ),
                child: Center(child: Icon(Icons.notifications_outlined,color: Colors.white,),),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    print("Paramètre de notifications");
                  },
                  child: ListTile(
                    title: Text("Notifications",style: TextStyle(
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
          Text("Support technique",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color( 0xFF2596be),//couleur.primaryPurple
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
                    borderRadius: BorderRadius.circular(10),
                    color: Color( 0xFF2596be),//couleur.primaryPurple
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
