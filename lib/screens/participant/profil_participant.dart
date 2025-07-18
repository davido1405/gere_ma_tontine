import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class profil_participant extends StatefulWidget {
  const profil_participant({super.key, required Session listsession});

  @override
  State<profil_participant> createState() => _profil_participantState();
}

class _profil_participantState extends State<profil_participant> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Profil utilisateur"),
    );
  }
}
