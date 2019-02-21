import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sprintf/sprintf.dart';

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
String showFraction(double num, {double tol=0.01, double maxDenom=10}){
  if((num.round() - num).abs() / num < tol){
    return "${num.round()}";
  }
  for(int denom = 2; denom <= maxDenom; denom++){
    double rounded = (num * denom).round() / denom;
    if((rounded - num).abs() / num < tol){
      return "${(num * denom).round()}/$denom";
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