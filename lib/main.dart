import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';import 'package:gerematontine/screens/splashScreen.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/constants/colors.dart';
import 'package:gerematontine/services/notifications_service.dart';

import 'constants/colors.dart'; // si tu utilises couleur.primaryPurple

Future<void> main(dynamic flutterLocalNotificationsPlugin) async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //await flutterLocalNotificationsPlugin.initialize();
  runApp(
     const MyApp(),
  );
  Future.delayed(const Duration(seconds: 2), () {
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          initialRoute: '/',
          routes: {
            '/': (context) => const splashScreen(),
            '/screens/auth/connexion_screen': (context) => const connexion_screen(),
          },
            home:child,
        );
      },
    );
  }
}

