import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Profile",style: TextStyle(
          fontWeight: FontWeight.bold
        ),),),
      ),
      body: Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 10),child:
        Column(
          children: [
            Center(child: Column(
              children: [
                CircleAvatar(
                  child: Image.asset("assets/profil.png"),
                  radius: 40,
                  backgroundColor: Colors.black,
                ),
                ListTile(
                  title: Center(
                    child: Text(widget.listsession.prenoms_participant+" "+widget.listsession.nom_participant,style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  subtitle: Center(child: Text(widget.listsession.email_participant)),
                ),
              ],
            ),),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>modifier_profil(listsession: widget.listsession,)));
              },
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: couleur.primaryPurple
                    ),
                    child: Icon(Icons.edit_document,color: Colors.white,),
                  ),Expanded(
                    child: ListTile(
                      title: Text("Modifier mon profil"),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>changer_mot_passe(listsession: widget.listsession,)));
              },
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: couleur.primaryPurple
                    ),
                    child: Icon(Icons.lock_outline,color: Colors.white,),
                  ),
                  Expanded(child: ListTile(
                    title: Text("Changer mon mot de passe"),
                  ))
                ],
              ),
            )
          ],
        )),
    );
  }
}
