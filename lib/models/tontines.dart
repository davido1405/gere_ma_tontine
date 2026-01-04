class Tontine {
  final String code_tontine;
  final String nom_tontine;
  final String montant_cotisation;
  final int nombre_participant;
  final String tour_actuel;
  final String frequence;
  final String frequence_paiement;
  final String cagnotte;
  final int participant_inscrit;
  final String type;
  late String etat;
  final String date_creation;
  final String code_wallet;

  Tontine({
    required this.code_tontine,
    required this.nom_tontine,
    required this.montant_cotisation,
    required this.nombre_participant,
    required this.tour_actuel,
    required this.frequence,
    required this.frequence_paiement,
    required this.cagnotte,
    required this.participant_inscrit,
    required this.type,
    required this.date_creation,
    required this.code_wallet,
    required this.etat,
  });

  factory Tontine.fromJson(Map<String, dynamic> json) {
    return Tontine(
      code_tontine: json['code_tontine']?.toString() ?? '',
      nom_tontine: json['nom']?.toString() ?? '',
      montant_cotisation: json['montant']?.toString() ?? '0',
      nombre_participant: _toInt(json['nombre_participant']),
      tour_actuel: json['tour_actuel']?.toString() ?? '0',
      frequence: json['frequence']?.toString() ?? '',
      frequence_paiement: json['frequence_paiement']?.toString() ?? '',
      cagnotte: json['cagnotte']?.toString() ?? '0',
      participant_inscrit: _toInt(json['participant_inscrit']),
      type: json['type']?.toString() ?? '',
      date_creation: json['date_creation']?.toString() ?? '',
      code_wallet: json['code_wallet']?.toString() ?? '',
      etat: json['etat_tontine']?.toString() ?? '',
    );
  }

  // ✅ Fonction helper pour convertir en int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}