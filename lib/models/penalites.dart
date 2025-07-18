class TotalPenali{
  final String total;

  TotalPenali({required this.total});
  factory TotalPenali.fromJson(Map<String,dynamic>json){
    return TotalPenali(total: json['data']);
  }
}

class Penalite{

  final String raison;
  final String montant;
  final String date_penalite;
  final String statut;
  final String date_paiement;

  Penalite({required this.raison, required this.montant, required this.date_penalite, required this.statut, required this.date_paiement});

  factory Penalite.fromJson(Map<String,dynamic>json){
    return Penalite(raison: json['raison'], montant: json['montant'].toString(), date_penalite: json['date_penalite'], statut: json['statut_paiement'], date_paiement: json['date_paiement']);
  }
}