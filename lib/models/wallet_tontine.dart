import 'dart:ffi';

class WalletTontine{
  late final String code_wallet;
  late final String code_tontine;
  late final int solde_tontine;

  WalletTontine({required this.code_wallet,required this.code_tontine,required this.solde_tontine});
  
  factory WalletTontine.fromJson(Map<String,dynamic>json){
    return WalletTontine(code_wallet: json['code_wallet'], code_tontine: json['code_tontine'], solde_tontine: json['solde']);
  }
}