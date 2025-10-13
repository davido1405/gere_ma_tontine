import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session{
  final String code_participant;
  final String nom_participant;
  final String prenoms_participant;
  final String type_participant;
  final String numero_participant;
  final String indice_solvabilite;
  final String niveau_kyc;
  late String  code_tontine;
  String? token;

  Session({required this.code_participant,required this.nom_participant,required this.prenoms_participant, required this.type_participant, required this.numero_participant,required this.indice_solvabilite,required this.niveau_kyc,required this.code_tontine,required this.token});

  factory Session.fromJson(Map<String,dynamic>json){
    return Session(code_participant: json['code_participant'], nom_participant: json['nom'], prenoms_participant: json['prenoms'], type_participant: json['type'], numero_participant: (json['numero']).toString(),indice_solvabilite: json['indice_solvabilite'].toString(),code_tontine: json['code_tontine'],  token: json['jwt_token'], niveau_kyc: json['niveau_kyc']);
  }

  void setCodeTontine(String tontineC){
    this.code_tontine=tontineC;
  }

  Future<void> secureJwt() async {
    final secureKey= FlutterSecureStorage();
    if (this.token != null) {
      await secureKey.write(key: 'jwt_token', value: token);
      this.token = null; // Supprime immédiatement la version non sécurisée
    }
  }

  Future<String?>getSecureJwt()async{
    final secureKey=FlutterSecureStorage();
   return await secureKey.read(key: 'jwt_token');
  }

  Future<void>removeToken()async {
    final removeSecure=FlutterSecureStorage();
    removeSecure.delete(key: 'jwt_token');
  }
}