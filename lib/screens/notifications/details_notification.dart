import 'package:flutter/material.dart';
import 'package:gerematontine/models/session.dart';

class details_notification extends StatefulWidget {
  const details_notification({super.key, required Session listsession});

  @override
  State<details_notification> createState() => _details_notificationState();
}

class _details_notificationState extends State<details_notification> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Details de notification"),
    );
  }
}
