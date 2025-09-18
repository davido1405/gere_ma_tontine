import 'dart:async';

import 'package:flutter/material.dart';

class VerificateurInactivite extends StatefulWidget {
  final Widget child;
  final Duration tempsMaxInactivite;
  final VoidCallback delaisDepasse;

  const VerificateurInactivite({super.key, required this.child, required this.tempsMaxInactivite, required this.delaisDepasse});

  @override
  State<VerificateurInactivite> createState() => _VerificateurInactiviteState();
}

class _VerificateurInactiviteState extends State<VerificateurInactivite> with WidgetsBindingObserver{
  Timer? tempsInactivite;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reinitialiserMinuteur();
  }

  @override
  void dispose(){
    tempsInactivite?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _reinitialiserMinuteur(){
    tempsInactivite?.cancel();
    tempsInactivite=Timer(widget.tempsMaxInactivite, widget.delaisDepasse);
  }

  void interactionDetecte(){
    _reinitialiserMinuteur();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state==AppLifecycleState.paused){
      //Démarrer le timer quand l'app passe en arrière plan
      tempsInactivite?.cancel();
      tempsInactivite=Timer(widget.tempsMaxInactivite,widget.delaisDepasse);
    }else if(state==AppLifecycleState.resumed){
      //Annuler le timer quand on revient dans l'application
      tempsInactivite?.cancel();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: interactionDetecte,
      onPanDown: (_)=>interactionDetecte(),
      child: widget.child,
    );
  }
}
