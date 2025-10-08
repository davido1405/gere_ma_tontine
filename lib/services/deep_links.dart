import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gerematontine/constants/server.dart';
import 'package:gerematontine/screens/auth/connexion_screen.dart';
import 'package:gerematontine/screens/auth/inscription_screen.dart';
import 'package:gerematontine/screens/dashboard/participer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  final BuildContext context;

  DeepLinkHandler({required this.context});

  void initDeepLinks() {
    // 1. App lancée via un lien
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _gererUri(uri);
      }
    });

    // 2. App déjà ouverte
    _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        _gererUri(uri);
      }
    });
  }

  Future<void> _gererUri(Uri uri) async {
    if (uri.host == "app" && uri.path == "/invite") {
      final token = uri.queryParameters['token'];
      if (token != null) {
        final prefs=await SharedPreferences.getInstance();
        prefs.setString('token_invitation', token);
      }
    }
  }
}
