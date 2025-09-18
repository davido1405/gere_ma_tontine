import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/services/notifications_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialise Firebase Messaging et récupère le token
  static Future<String?> initializeFCM() async {
    // Demande l'autorisation pour iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Permission refusée pour les notifications');
      return null;
    }

    // Récupère le token FCM
    String? token = await _messaging.getToken();
    if(token!=null){
      final prefs=await SharedPreferences.getInstance();
      prefs.setString('fcm_token', token);
    }
    print("FCM Token: $token");

    // Écoute les messages en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification!=null){
        NotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: message.notification!.title ?? '',
            body: message.notification!.body ?? '');
      }
      print('Message reçu en foreground: ${message.notification?.title}');
    });
    return token;
  }

  /// Envoie le token FCM au serveur
  static Future<bool> sendFCMTokenToServer(String token, String codeParticipant) async {
    try {
      final url = Uri.parse("${adress}?ressource=participants&action=recuperer_fcm_token");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            'fcm_token': token,
            'code_participant': codeParticipant
          }
        ),
      );

      if (response.statusCode == 200) {
        print("Token FCM envoyé avec succès au serveur");
        return true;
      } else {
        print("Erreur lors de l'envoi du token: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception lors de l'envoi du token: $e");
      return false;
    }
  }
}
