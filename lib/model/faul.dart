part of '../common.dart';

class Faul {
  int number;
  Faul({required this.number});

  static Faul fromJson(Map<String, dynamic> json) {
    return Faul(number: json['number']);
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
    };
  }
}
