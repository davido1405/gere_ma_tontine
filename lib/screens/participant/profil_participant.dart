import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/participant/changer_mot_passe.dart';
import 'package:gerematontine/screens/participant/modifier_profil.dart';

class profil_participant extends StatefulWidget {
  final Session listsession;
  const profil_participant({super.key, required this.listsession});

  @override
  State<profil_participant> createState() => _profil_participantState();
}

class _profil_participantState extends State<profil_participant> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Color getRandomColor( String input){
    final hash=input.hashCode;
    final couleurs=[Colors.deepOrange,Colors.amber,Colors.cyan,Colors.green,couleur.primaryPurple,Colors.red,Colors.blue];
    return couleurs[hash % couleurs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Profile",style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold
        ),),),
      ),
      body: Padding(padding: EdgeInsets.only(left: 10.w,right: 10.w,top: 10.h),child:
        Column(
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
                    child: Text("${widget.listsession.prenoms_participant} ${widget.listsession.nom_participant}",style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  subtitle: Center(child: Text(widget.listsession.email_participant,style: TextStyle(
                    fontSize: 14.sp
                  ),)),
                ),
              ],
            ),),
            SizedBox(
              height: 15.h,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>modifier_profil(listsession: widget.listsession,)));
              },
              child: Row(
                children: [
                  Container(
                    width: 45.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: couleur.primaryPurple
                    ),
                    child: Icon(Icons.edit_document,color: Colors.white,),
                  ),Expanded(
                    child: ListTile(
                      title: Text("Modifier mon profil",style: TextStyle(
                        fontSize: 16.sp
                      ),),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>changer_mot_passe(listsession: widget.listsession,)));
              },
              child: Row(
                children: [
                  Container(
                    width: 45.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: couleur.primaryPurple
                    ),
                    child: Icon(Icons.lock_outline,color: Colors.white,),
                  ),
                  Expanded(child: ListTile(
                    title: Text("Changer mon mot de passe",style: TextStyle(
                        fontSize: 16.sp
                    ),),
                  ))
                ],
              ),
            )
          ],
        )),
    );
  }
}
