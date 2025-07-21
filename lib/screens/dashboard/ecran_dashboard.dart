import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/cotisations/payer_cotisation.dart';
import 'package:gerematontine/screens/dashboard/Acceuil.dart';
import 'package:gerematontine/screens/notifications/liste_notifications.dart';
import 'package:gerematontine/screens/parametres.dart';
import 'package:gerematontine/screens/participant/profil_participant.dart';
import 'package:gerematontine/screens/tontine/creer_tontine.dart';
import 'package:gerematontine/screens/tontine/details_tontine.dart';
import 'package:gerematontine/screens/tontine/participer_tontine.dart';
import '../participant/changer_mot_passe.dart';
import '../participant/modifier_profil.dart';
import '../participant/mon_tour.dart';
import '../penalites/payer_penalite.dart';

class dashboard extends StatefulWidget {
  final Session listsession;

  const dashboard({super.key, required this.listsession});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {

  int _selectedIndex=0;
  void _onTap(int index){
    setState(() {
      _selectedIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget>_pages=[
      acceuil(listsession:widget.listsession),
      details_tontine(listsession:widget.listsession),
      notifications(listsession:widget.listsession),
      profil_participant(listsession:widget.listsession),
      notifications(listsession:widget.listsession),
      changer_mot_passe(listsession:widget.listsession),
      modifier_profil(listsession:widget.listsession),
      mon_tour(listsession:widget.listsession),
      payer_penalite(listsession:widget.listsession),
      creer_tontine(listsession:widget.listsession),
      participer_tontine(listsession:widget.listsession),
      parametre(listsession:widget.listsession)
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: [
        BottomNavigationBarItem(label: "Home", icon: Icon(_selectedIndex==0 ? Icons.home_outlined:Icons.home)),
        BottomNavigationBarItem(label: "Détails tontine",icon: Icon(_selectedIndex==1 ? Icons.groups_outlined:Icons.groups)),
        BottomNavigationBarItem(label: "Notifications",icon: Icon(_selectedIndex==2 ? Icons.notifications_outlined:Icons.notifications)),
        BottomNavigationBarItem(label: "Profil",icon: Icon(_selectedIndex==3 ? Icons.person_outline:Icons.person))
      ],
        selectedItemColor: couleur.iconActive,
        showSelectedLabels: true,
        unselectedItemColor: couleur.iconInactive,
      ),
    );
  }
}
