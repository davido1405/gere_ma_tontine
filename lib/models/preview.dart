class PreviewCotisation{

  final int cotisations_manquees;
  final String situtaion_tour;
  final int tour_avance;
  final int total_frais;
  final int total_transaction;

  PreviewCotisation({required this.cotisations_manquees,required this.situtaion_tour,required this.tour_avance,required this.total_frais,required this.total_transaction});

  factory PreviewCotisation.fromJson(Map<String,dynamic>json){
    return PreviewCotisation(cotisations_manquees: json['cotisations_manquees'], situtaion_tour: json['situation_tour'].toString(), tour_avance: json['tours_avance'], total_frais: json['frais_totaux'], total_transaction: json['total_transaction']);
  }
}