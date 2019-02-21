import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sprintf/sprintf.dart';

const List<String> _superscripts = [
  "\u{2070}",
  "\u{00B9}",
  "\u{00B2}",
  "\u{00B3}",
  "\u{2074}",
  "\u{2075}",
  "\u{2076}",
  "\u{2077}",
  "\u{2078}",
  "\u{2079}",
];

const List<String> _subscripts = [
  "\u{2080}",
  "\u{2081}",
  "\u{2082}",
  "\u{2083}",
  "\u{2084}",
  "\u{2085}",
  "\u{2086}",
  "\u{2087}",
  "\u{2088}",
  "\u{2089}",
];

const String _slash = "\u{2044}";

double parseFraction(String str){
  str = str.trim();
  if(RegExp(r"^\d+(\.\d+)?(\s*\/\s*\d+(\.\d+)?)?$").hasMatch(str)){
    List<String> split = str.split("/");
    assert(split.length <= 2);
    double numerator = double.parse(split[0].trim());
    double denominator = split.length == 2 ? double.parse(split[1].trim()) : 1.0;
    return numerator / denominator;
  }else{
    return null;
  }
}

//TODO: Pretty printing (Use unicode fractions)
String showFraction(double num,
    {double tol=0.01, double maxDenom=10, bool binaryDenom=false, bool unicode=false}){
  if((num.round() - num).abs() / num < tol){
    return "${num.round()}";
  }
  for(int denom = 2; denom <= maxDenom; denom = binaryDenom ? denom * 2 : denom + 1){
    double rounded = (num * denom).round() / denom;
    if((rounded - num).abs() / num < tol){
      debugPrint("Num: $num, Numerator: ${(num * denom).round()}, Denom: $denom");
      if(unicode){
        return "${(num * denom).round()}" + _slash + "$denom";
      }else {
        return "${(num * denom).round()}/$denom";
      }
    }
  }
  return showDecimal(num, precision: (-log(tol) / log(10)).ceil());
}

String showDecimal(double num, {int precision=2}){
  if(num >= pow(10, precision - 1) || num % 1.0 == 0){
    return "${num.round()}";
  }else if(num > 1){
    return sprintf("%.1f", [num]);
  }else{
    int afterDecimal = (log(num) / log(10)).abs().ceil() + precision - 1;
    debugPrint("Num=$num, afterDecimal=$afterDecimal");

    return sprintf("%.${afterDecimal}f", [num]);
  }
}