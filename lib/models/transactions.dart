class Transactions{
  late final String nom;
  late final String prenoms;
  late final String type_transaction;
  late final String montant_transaction;
  late final String date_transaction;
  late final String mode_paiement;
  late final int statut_paiement;
  Transactions({required this.nom,required this.prenoms,required this.type_transaction,required this.montant_transaction,required this.date_transaction,required this.mode_paiement,required this.statut_paiement});

  factory Transactions.fromJson(Map<String,dynamic>json){
    return Transactions(nom: json['nom'], prenoms: json['prenoms'], type_transaction: json['type_transaction'], montant_transaction: json['montant_transaction'], date_transaction: json['date_transaction'], mode_paiement: json['mode_paiement'], statut_paiement: json['statut_paiement']);
  }
}