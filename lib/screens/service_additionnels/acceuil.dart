import 'package:flutter/material.dart';
import 'package:gerematontine/screens/service_additionnels/assurances.dart';
import 'package:gerematontine/screens/service_additionnels/epargne.dart';
import 'package:gerematontine/screens/service_additionnels/micro_credit.dart';

class acceuil_services_partenaire extends StatefulWidget {
  const acceuil_services_partenaire({super.key});

  @override
  State<acceuil_services_partenaire> createState() => _acceuil_services_partenaireState();
}

class _acceuil_services_partenaireState extends State<acceuil_services_partenaire> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Services Partenaire"),),
        bottom: TabBar(tabs: [
          Tab(icon: Icon(Icons.security),),
          Tab(icon: Icon(Icons.assured_workload),),
          Tab(icon: Icon(Icons.savings),)
        ])
        ),
      body: TabBarView(children: [
        ecran_service_assurance(),
        ecran_services_micro_credit(),
        ecran_services_epargne(),
      ]),
    );
  }
}
