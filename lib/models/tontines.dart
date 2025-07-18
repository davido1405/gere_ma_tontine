class Tontine{
  final String code_tontine;
  final String nom_tontine;
  final String montant_cotisation;
  final int nombre_participant;
  final String frequence;
  final String type;
  final String date_creation;

  Tontine({required this.code_tontine,required this.nom_tontine,required this.montant_cotisation, required this.nombre_participant,required this.frequence, required this.type, required this.date_creation});

  factory Tontine.fromJson(Map<String,dynamic>json){
    return Tontine(code_tontine: json['code_tontine'], nom_tontine: json['nom'], montant_cotisation: json['montant'], nombre_participant: json['nombre participant'], frequence: json['frequence'], type: json['type'], date_creation: json['date creation']);
  }
}