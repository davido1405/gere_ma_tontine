class Membre{
  final String code_membre;
  final String nom_membre;
  final String prenom_membre;
  final String numero;
  final String date_participation;
  final String type;
  final String points_confiance;

  Membre({required this.code_membre,required this.nom_membre, required this.prenom_membre, required this.numero, required this.date_participation, required this.type, required this.points_confiance});

  factory Membre.fromJson(Map<String,dynamic>json){
    return Membre(nom_membre: json['nom'], prenom_membre: json['prenoms'], numero: json['mobile'], date_participation: json['date_participation'], type: json['type'], points_confiance: json['points_confiance'].toString(), code_membre: json['code_participant']);
  }
}