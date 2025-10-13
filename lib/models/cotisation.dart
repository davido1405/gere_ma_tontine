class Cotisation{
  final String code_cotisation;
  final String montant;
  final String tour_avance;
  final String date_paiement;
  final String mode_paiement;
  final String statut_paiement;

  Cotisation({required this.code_cotisation, required this.montant,required this.tour_avance,required this.date_paiement,required this.mode_paiement,required this.statut_paiement});

  factory Cotisation.fromJson(Map<String, dynamic>json){
    return Cotisation(code_cotisation:json['code_cotisation'],montant:double.parse(json['montant']).toString(),date_paiement:json['date_paiement'],mode_paiement:json['mode_paiement'],statut_paiement:json['statut_paiement'], tour_avance: json['nombre_tour_avance'].toString());
  }
}