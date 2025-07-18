import 'package:flutter/foundation.dart';

class TotalCoti{
  final String total;

  TotalCoti({required this.total});
  factory TotalCoti.fromJson(Map<String,dynamic>json){
    return TotalCoti(total: json['data'].toString());
  }
}