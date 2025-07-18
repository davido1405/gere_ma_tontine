class Notifications{
  final String id_notif;
  final String contenu_notif;
  final String date_envoie;
  late final String statut_notif;
  final String type_notif;

  Notifications({required this.id_notif,required this.contenu_notif,required this.date_envoie,required this.statut_notif, required this.type_notif});

  factory Notifications.fromJson(Map<String,dynamic>json){
    return Notifications(id_notif: (json['id_notification']).toString(),contenu_notif: json['contenu_notification'],date_envoie: json['date_envoie'],statut_notif: json['statut_notification'],type_notif: json['type_notification']);
  }
}