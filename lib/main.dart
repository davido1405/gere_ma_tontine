import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';import 'package:gerematontine/screens/splashScreen.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'constants/colors.dart'; // si tu utilises couleur.primaryPurple

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await flutterLocalNotificationsPlugin.initialize();

  Future.delayed(Duration(seconds: 2),(){
    FlutterNativeSplash.remove();
  });

  runApp(
     const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? nom;
  String? prenom;
  String? numero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize: const Size(412, 915),//Dimenssion de l'écran utilisé dans le dévéloppement
      minTextAdapt: true,//Adapter la taille des textes
      splitScreenMode: true,//Accepter les écrans partagés/tablette
      builder: (context, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          //initialRoute: numero!=null?'/screens/auth/connexion_screen':'/screens/auth/inscription_screen',
          //routes: {
            //'/': (context) => const splashScreen(),
            //'/screens/auth/connexion_screen': (context) => const connexion_screen(),
            //'/screens/auth/inscription_screen':(context)=>const inscription_screen()
          //},
            home:const splashScreen(),
        );
      },
    );
  }
}

