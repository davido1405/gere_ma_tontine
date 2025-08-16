class Beneficiare{
  final String codeBeneficiare;
  final String nomBeneficiare;
  final String prenomsBeneficiare;
  final int positionBeneficiare;
  final int statutBeneficiare;

  Beneficiare( {required this.codeBeneficiare,required this.nomBeneficiare, required this.prenomsBeneficiare,required this.positionBeneficiare,required this.statutBeneficiare});

  factory Beneficiare.fromJson(Map<String,dynamic>json){
    return Beneficiare(codeBeneficiare: json['code_participant'],nomBeneficiare: json['nom_participant'], prenomsBeneficiare: json['prenoms_participant'], positionBeneficiare: json['ordre'],statutBeneficiare: json['statut']);
  }
}