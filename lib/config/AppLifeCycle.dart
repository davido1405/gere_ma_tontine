import 'dart:async';
import 'package:flutter/material.dart';

class VerificateurInactivite extends StatefulWidget {
  final Widget child;
  final Duration tempsMaxInactivite;
  final VoidCallback delaisDepasse;

  const VerificateurInactivite({
    super.key,
    required this.child,
    required this.tempsMaxInactivite,
    required this.delaisDepasse,
  });

  @override
  State<VerificateurInactivite> createState() => _VerificateurInactiviteState();
}

class _VerificateurInactiviteState extends State<VerificateurInactivite> with WidgetsBindingObserver {
  Timer? tempsInactivite;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ne rien démarrer ici
  }

  @override
  void dispose() {
    tempsInactivite?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _demarrerMinuteur() {
    tempsInactivite?.cancel();
    tempsInactivite = Timer(widget.tempsMaxInactivite, widget.delaisDepasse);
  }

  void _annulerMinuteur() {
    tempsInactivite?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // L'app est passée en arrière-plan -> démarrer le timer
      _demarrerMinuteur();
    } else if (state == AppLifecycleState.resumed) {
      // L'app est revenue au premier plan -> annuler le timer
      _annulerMinuteur();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Plus besoin de GestureDetector si on ne suit que l'arrière-plan
  }
}
