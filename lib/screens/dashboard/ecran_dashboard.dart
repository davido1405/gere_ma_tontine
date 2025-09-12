import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart' as bades;
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/cotisations/payer_cotisation.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:gerematontine/screens/notifications/liste_notifications.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/tontine/creer_tontine.dart';
import 'package:gerematontine/screens/tontine/details_tontine.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:http/http.dart';
import '../../constants/server.dart';
import '../../models/notification.dart';
import '../participant/changer_mot_passe.dart';
import '../penalites/payer_penalite.dart';

class dashboard extends StatefulWidget {
  final Session listsession;

  const dashboard({super.key, required this.listsession});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {

  @override
  void initState() {
    // TODO: implement initState
    recupererNotif();
    Timer.periodic(Duration(seconds: 3), (timer){
      recupererNotif();
    });
  }

  int _selectedIndex=0;
  void _onTap(int index){
    setState(() {
      _selectedIndex=index;
    });
  }

  List<Notifications>_listnotification=[];


  Future<void>recupererNotif()async {
    final url=Uri.parse("${adress}?ressource=notifications&action=lister_notification");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":widget.listsession.code_participant,
          "filtre":"Non lu"
        })).timeout(Duration(seconds: 15));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success && data['data']!=null){
        List<dynamic>notifs=data['data'];
        setState(() {
          _listnotification=notifs.map((notifs)=>Notifications.fromJson(notifs)).toList();
        });
        //for(int i=0;i<_listnotification.length;i++){
          //Notifications notifications=_listnotification[0];
          //NotificationService.showNotification(id: int.parse(notifications.id_notif), title: notifications.type_notif, body: notifications.contenu_notif);
        //}
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

  @override
  Widget build(BuildContext context) {
    final List<Widget>_pages=[
      acceuil(listsession:widget.listsession),
      details_tontine(listsession:widget.listsession),
      notifications(listsession:widget.listsession),
      changer_mot_passe(listsession:widget.listsession),
      payer_penalite(listsession:widget.listsession),
      creer_tontine(listsession:widget.listsession),
      parametre(listsession:widget.listsession)
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: [
        BottomNavigationBarItem(label: "Home", icon: Icon(_selectedIndex==0 ? Icons.home_outlined:Icons.home)),
        BottomNavigationBarItem(label: "Détails tontine",icon: Icon(_selectedIndex==1 ? Icons.groups_outlined:Icons.groups)),
        BottomNavigationBarItem(label: "Notifications",icon: bades.Badge(
          badgeStyle: bades.BadgeStyle(
            badgeColor: Colors.orange,
          ),
          badgeContent: Text("${_listnotification.length}"),
          child: Icon(_selectedIndex==2 ? Icons.notifications_outlined:Icons.notifications),
        )),
        ],
        selectedItemColor: couleur.iconActive,
        showSelectedLabels: true,
        unselectedItemColor: couleur.iconInactive,
      ),
    );
  }
}
