import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/notification.dart';
import 'package:http/http.dart';

class notifications extends StatefulWidget {
  final Session listsession;
  const notifications({super.key, required this.listsession});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recupererNotif();
  }
  bool _lu=false;
  bool _nonlu=false;
  bool _ouvert=false;

  String filre="Tous";
  List<Notifications>_listnotification=[];


  Future<void>recupererNotif()async {
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=notifications&action=lister_notification");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "filtre":filre,
        })).timeout(Duration(seconds: 30));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success && data['data']!=null){
        List<dynamic>notifs=data['data'];
        setState(() {
          _listnotification=notifs.map((notifs)=>Notifications.fromJson(notifs)).toList();
        });
      }else{
        setState(() {
          _listnotification=[];
        });
        print("Aucune notification");
      }
    }else{
      print("Erreur serveur : ${reponse.statusCode}");
    }
  }

  void marquerCommelu(int x) async{
    final url=Uri.parse("http://10.0.2.2/Projets/tontine_plus_api/index.php?ressource=notifications&action=lire_notification");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "id_notification":x
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);

      if(data['success']==true){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text("Confirmation"),),
            content: Text("Message marqué lu"),
            actions: [
              Center(child: TextButton.icon(onPressed: (){
                Navigator.of(context).pop();
              }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
            ],
          );
        });
        print("Message marqué lu");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if(_listnotification==null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Notifications",style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Padding(padding: EdgeInsets.only(left: 10,right: 10),
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  TextButton.icon(onPressed: (){
                    setState(() {
                      _lu=true;
                      _nonlu=false;
                      filre="Lu";
                    });
                    recupererNotif();
                  }, label: Text("Lu"),style: TextButton.styleFrom(
                      backgroundColor: _lu ? Color(0xFFB39DDB) : Color(0xFFD1C4E9)
                  ) ,),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton.icon(onPressed: (){
                    setState(() {
                      _lu=false;
                      _nonlu=true;
                      filre="Non lu";
                    });
                    recupererNotif();
                  }, label: Text("Non lu"),style: TextButton.styleFrom(
                      backgroundColor: _nonlu ? Color(0xFFB39DDB) : Color(0xFFD1C4E9)
                  ) ,),
                ],
              ))
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              height: 350,
            width: 400,
            child: Column(
              children: [
                Expanded(child: ListView.builder(
                  itemCount: _listnotification.length,
                    itemBuilder: (context,index){
                    final Notifications notifica=_listnotification[index];
                    return GestureDetector(
                      onTap: (){
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(
                            title: Center(child: Text("Details notification"),),
                            content: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width*0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notifica.type_notif,
                                  overflow: TextOverflow.ellipsis,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(notifica.contenu_notif,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(notifica.date_envoie),
                                ],
                              ),
                            ),
                            actions: [
                              Center(child: TextButton.icon(onPressed: (){
                                Navigator.of(context).pop();
                                marquerCommelu(int.parse(notifica.id_notif));
                                recupererNotif();
                              }, label: Text("OK"),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
                            ],
                          );
                        });
                      },
                      child: ListTile(
                        title: Row(
                          children: [
                            Column(
                              children: [
                                Text(notifica.type_notif,style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500
                                ),),
                              ],
                            ),
                            SizedBox(
                              width: 125,
                            ),
                            Column(
                              children: [
                                Icon(
                                  notifica.statut_notif == "Lu"
                                      ? Icons.done_all // lu
                                      : Icons.done,    // non lu
                                  color: notifica.statut_notif == "Lu"
                                      ? Colors.blue   // couleur pour "lu"
                                      : Colors.grey,  // couleur pour "non lu"
                                ),
                              ],
                            )
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notifica.contenu_notif.substring(0,25)+"...",style: TextStyle(
                                fontSize: 15
                            ),),
                            Text(notifica.date_envoie)
                          ],
                        ),
                      ),
                    );

                })),
              ],
            )
          )
        ],
      ),),
    );
  }
}
