import 'dart:convert';

class Session{
  final String code_participant;
  final String nom_participant;
  final String prenoms_participant;
  final String email_participant;
  final String type_participant;
  final String code_tontine;

  Session({required this.code_participant,required this.nom_participant,required this.prenoms_participant, required this.email_participant,required this.type_participant,required this.code_tontine});

  factory Session.fromJson(Map<String,dynamic>json){
    return Session(code_participant: json['code_participant'], nom_participant: json['nom'], prenoms_participant: json['prenoms'], email_participant: json['email'], type_participant: json['type'], code_tontine: json['code_tontine']);
  }
}