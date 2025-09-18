class Tontine{
  final String code_tontine;
  final String nom_tontine;
  final String montant_cotisation;
  final int nombre_participant;
  final String frequence;
  final String frequence_paiement;
  final String type;
  late String etat;
  final String date_creation;
  final String code_wallet;

  Tontine({required this.code_tontine,required this.nom_tontine,required this.montant_cotisation, required this.nombre_participant,required this.frequence, required this.type, required this.date_creation,required this.code_wallet,required this.frequence_paiement,required this.etat});

  factory Tontine.fromJson(Map<String,dynamic>json){
    return Tontine(code_tontine: json['code_tontine'], nom_tontine: json['nom'], montant_cotisation: json['montant'], nombre_participant: json['nombre_participant'], frequence: json['frequence'], type: json['type'], date_creation: json['date_creation'], code_wallet: json['code_wallet'],frequence_paiement: json['frequence_paiement'],etat: json['etat_tontine']);
  }
}