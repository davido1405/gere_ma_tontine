class InfosWallet {
  final double solde_participant;
  final double transaction_journaliere;
  final double transaction_mois;
  final double limite_kyc_jour;
  final double limite_kyc_mois;

  InfosWallet({
    required this.solde_participant,
    required this.transaction_journaliere,
    required this.transaction_mois,
    required this.limite_kyc_jour,
    required this.limite_kyc_mois,
  });

  factory InfosWallet.fromJson(Map<String, dynamic> json) {
    return InfosWallet(
      solde_participant: _toDouble(json['solde_participant']),
      transaction_journaliere: _toDouble(json['transaction_journaliere']),
      transaction_mois: _toDouble(json['transaction_mois']),
      limite_kyc_jour: _toDouble(json['limite_kyc_jour']),
      limite_kyc_mois: _toDouble(json['limite_kyc_mois']),
    );
  }

  // ✅ Fonction sécurisée qui gère tous les cas
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}