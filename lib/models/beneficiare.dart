class Beneficiare {
  final String codeBeneficiare;
  final String nomBeneficiare;
  final String prenomsBeneficiare;
  final int positionBeneficiare;
  final int statutBeneficiare; // ✅ Gardez pour compatibilité
  final String etatBeneficiare; // ✅ NOUVEAU - 'en_cours', 'complete', 'a_venir'
  final String dateTour;
  final double? montant;

  Beneficiare({
    required this.codeBeneficiare,
    required this.nomBeneficiare,
    required this.prenomsBeneficiare,
    required this.positionBeneficiare,
    required this.statutBeneficiare,
    required this.etatBeneficiare, // ✅ NOUVEAU
    required this.dateTour,
    this.montant,
  });

  factory Beneficiare.fromJson(Map<String, dynamic> json) {
    return Beneficiare(
      codeBeneficiare: json['code_participant'] ?? '',
      nomBeneficiare: json['nom_participant'] ?? '',
      prenomsBeneficiare: json['prenoms_participant'] ?? '',
      positionBeneficiare: json['ordre'] ?? 0,
      statutBeneficiare: json['statut'] ?? 0,
      etatBeneficiare: json['etat'] ?? 'a_venir', // ✅ NOUVEAU avec valeur par défaut
      dateTour: json['date_tour'] ?? '',
      montant: json['montant']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_participant': codeBeneficiare,
      'nom_participant': nomBeneficiare,
      'prenoms_participant': prenomsBeneficiare,
      'ordre': positionBeneficiare,
      'statut': statutBeneficiare,
      'etat': etatBeneficiare, // ✅ NOUVEAU
      'date_tour': dateTour,
      'montant': montant,
    };
  }
}