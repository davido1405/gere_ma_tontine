class Membre{
  final String nom_membre;
  final String prenom_membre;
  final String numero;
  final String date_participation;
  final String type;

  Membre({required this.nom_membre, required this.prenom_membre, required this.numero, required this.date_participation, required this.type});

  factory Membre.fromJson(Map<String,dynamic>json){
    return Membre(nom_membre: json['nom'], prenom_membre: json['prenoms'], numero: json['mobile'], date_participation: json['date_participation'], type: json['type']);
  }
}