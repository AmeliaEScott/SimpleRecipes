

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
  return "$num";
}
