class Beneficiare{
  final String codeBeneficiare;
  final String nomBeneficiare;
  final String prenomsBeneficiare;
  final int positionBeneficiare;
  final int statutBeneficiare;
  final String dateTour;

  Beneficiare( {required this.codeBeneficiare,required this.nomBeneficiare, required this.prenomsBeneficiare,required this.positionBeneficiare,required this.statutBeneficiare,required this.dateTour});

  factory Beneficiare.fromJson(Map<String,dynamic>json){
    return Beneficiare(codeBeneficiare: json['code_participant'],nomBeneficiare: json['nom_participant'], prenomsBeneficiare: json['prenoms_participant'], positionBeneficiare: json['ordre'],statutBeneficiare: json['statut'], dateTour: (json['date_prevu']).toString(),);
  }
}