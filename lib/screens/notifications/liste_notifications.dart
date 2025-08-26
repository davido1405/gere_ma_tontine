import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/models/notification.dart';
import 'package:http/http.dart';

import '../../constants/server.dart';

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
    Timer.periodic(Duration(seconds: 3),(timer){
      recupererNotif();
    });
  }
  bool _lu=false;
  bool _nonlu=false;
  bool _ouvert=false;

  String filre="Tous";
  List<Notifications>_listnotification=[];


  Future<void>recupererNotif()async {
    final url=Uri.parse("${adress}?ressource=notifications&action=lister_notification");
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
    final url=Uri.parse("${adress}?ressource=notifications&action=lire_notification");
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
            title: Center(child: Text("Confirmation",style: TextStyle(
                fontSize: 15.sp
            ),),),
            content: Text("Message marqué lu",style: TextStyle(
              fontSize: 14.sp
            ),),
            actions: [
              Center(child: TextButton.icon(onPressed: (){
                Navigator.of(context).pop();
              }, label: Text("OK",style: TextStyle(
                  fontSize: 14.sp
              ),),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
            ],
          );
        });
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Notifications",style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: recupererNotif,
        child: Padding(padding: EdgeInsets.only(left: 10.w,right: 10.w),
        child: Column(
          children: [
            SizedBox(
              height: 15.h,
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
                    }, label: Text("Lu",style: TextStyle(
                        fontSize: 14.sp
                    ),),style: TextButton.styleFrom(
                        backgroundColor: _lu ? Color(0xFFB39DDB) : Color(0xFFD1C4E9)
                    ) ,),
                    SizedBox(
                      width: 10.h,
                    ),
                    TextButton.icon(onPressed: (){
                      setState(() {
                        _lu=false;
                        _nonlu=true;
                        filre="Non lu";
                      });
                      recupererNotif();
                    }, label: Text("Non lu",style: TextStyle(
                        fontSize: 14.sp
                    ),),style: TextButton.styleFrom(
                        backgroundColor: _nonlu ? Color(0xFFB39DDB) : Color(0xFFD1C4E9)
                    ) ,),
                  ],
                ))
              ],
            ),
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
                height: 600.h,
              width: 400.w,
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
                              title: Center(child: Text("Détails notification",style: TextStyle(
                                  fontSize: 16.sp
                              ),),),
                              content: SizedBox(
                                height: 145.h,
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notifica.type_notif,
                                    overflow: TextOverflow.ellipsis,),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text(notifica.contenu_notif,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,),
                                    SizedBox(
                                      height: 5.h,
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
                                }, label: Text("OK",style: TextStyle(
                                    fontSize: 14.sp
                                ),),icon: Icon(Icons.verified,color: Colors.lightGreen,),),)
                              ],
                            );
                          });
                        },
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(notifica.type_notif,style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500
                                  ),),
                                ],
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
                              Text("${notifica.contenu_notif.substring(0,25)}...",style: TextStyle(
                                  fontSize: 15.sp
                              ),),
                              Text(notifica.date_envoie,style: TextStyle(
                                  fontSize: 14.sp
                              ),)
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
      ),
    );
  }
}
