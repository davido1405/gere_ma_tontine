class Beneficiare {
  final String codeBeneficiare;
  final String nomBeneficiare;
  final String prenomsBeneficiare;
  final int positionBeneficiare;
  final int statutBeneficiare;  // 0 = à venir, 1 = en cours, 2 = complété
  final String etat;  // 'complete', 'en_cours', 'a_venir'
  final String dateTour;
  final double montant;

  Beneficiare({
    required this.codeBeneficiare,
    required this.nomBeneficiare,
    required this.prenomsBeneficiare,
    required this.positionBeneficiare,
    required this.statutBeneficiare,
    required this.etat,
    required this.dateTour,
    required this.montant,
  });

  factory Beneficiare.fromJson(Map<String, dynamic> json) {
    return Beneficiare(
      codeBeneficiare: json['code_participant']?.toString() ?? '',
      nomBeneficiare: json['nom_participant']?.toString() ?? '',
      prenomsBeneficiare: json['prenoms_participant']?.toString() ?? '',
      positionBeneficiare: json['ordre'] is int
          ? json['ordre']
          : int.tryParse(json['ordre']?.toString() ?? '0') ?? 0,
      statutBeneficiare: json['statut'] is int
          ? json['statut']
          : int.tryParse(json['statut']?.toString() ?? '0') ?? 0,
      etat: json['etat']?.toString() ?? 'a_venir',
      dateTour: json['date_tour']?.toString() ?? '',
      montant: _toDouble(json['montant']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}