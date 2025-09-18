import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage, FirebaseMessaging;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/screens/splashScreen.dart';
import 'package:gerematontine/services/fcm_service.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart' show Workmanager;
import 'constants/server.dart';
import 'firebase_options.dart';
import 'models/notification.dart';


// ⚠️ Handler pour les messages FCM en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.initialize(); // initialise le plugin
  NotificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialisation nécessaire
    await NotificationService.initialize();

    final prefs = await SharedPreferences.getInstance();
    final codeParticipant = prefs.getString('code_participant');

    if (codeParticipant != null) {
      try {
        final url = Uri.parse("${adress}?ressource=notifications&action=lister_notification");
        final reponse = await http.post(
          url,
          headers: {"content-Type": "application/json"},
          body: jsonEncode({
            "code_participant": codeParticipant,
            "filtre": "Non lu"
          }),
        );

        if (reponse.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(reponse.body);
          bool success = data['success'];

          if (success && data['data'] != null) {
            List<dynamic> notifs = data['data'];

            for (var notif in notifs) {
              final n = Notifications.fromJson(notif);
              NotificationService.showNotification(
                id: int.parse(n.id_notif),
                title: n.type_notif,
                body: n.contenu_notif,
              );
            }
          }
        }
      } catch (e) {
        print("Erreur Workmanager: $e");
      }
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  // ⚡ Init Workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // mets false en prod
  );

  // ⚡ Tâche périodique toutes les 15 minutes
  await Workmanager().registerPeriodicTask(
    "checkNotifTask",
    "recupererNotifTask",
    frequency: const Duration(minutes: 15),
  );

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

  bool erreur=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initialiserFirebase();
    // ✅ Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title ?? "",
          body: message.notification!.body ?? "",
        );
        // 👉 Ici tu peux appeler ton API pour sync
        recupererNotif();
      }
    });

    // ✅ Background (notification cliquée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // 👉 Navigue ou récupère tes notifs depuis l’API
      recupererNotif();
    });

    // ✅ Terminated (app ouverte via une notif)
    checkInitialMessage();
  }

  Future<void>initialiserFirebase()async{
    try{
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FCMService.initializeFCM();
      // ⚡ Déclare le handler pour les notifications en background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      setState(() {
        erreur=false;
      });
    }catch(e){
      setState(() {
        erreur=true;
      });}
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("🚀 App lancée via une notification");
      recupererNotif();
    }
  }

  List<Notifications>_listnotification=[];

  Future<void>recupererNotif()async {
    final prefs=await SharedPreferences.getInstance();
    final url=Uri.parse("${adress}?ressource=notifications&action=lister_notification");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "code_participant":prefs.getString('code_participant'),
          "filtre":"Non lu"
        })).timeout(Duration(seconds: 30));
    if(reponse.statusCode==200){
      final Map<String,dynamic>data=jsonDecode(reponse.body);
      bool success=data['success'];
      if(success && data['data']!=null){
        List<dynamic>notifs=data['data'];
        setState(() {
          _listnotification=notifs.map((notifs)=>Notifications.fromJson(notifs)).toList();
        });
        for(int i=0;i<_listnotification.length;i++){
          Notifications notifications=_listnotification[1];
          NotificationService.showNotification(
              id: int.parse(notifications.id_notif),
              title: notifications.type_notif,
              body: notifications.contenu_notif);
        }
      }
    }else{
      print("Erreur serveur : ${reponse.statusCode}");
    }
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
            home:erreur==true? Center(
              child: Column(
                children: [
                  Image.asset('assets/6.png',width: 100.w,height: 100.h,),
                  SizedBox(height: 20.h,),
                  Text("Veuillez vérifier votre connexion internet. Merci"),
                  SizedBox(
                    height: 100.h,
                  ),
                  TextButton(onPressed: (){
                    initialiserFirebase();
                  }, child: Text("Réessayer"))
                ],
              ),
            ):
            const splashScreen(),
        );
      },
    );
  }
}

