import 'package:sprintf/sprintf.dart';
import 'package:flutter/foundation.dart';
import 'util.dart';

class Recipe {
  final int id;

  String name = "";
  String description = "";

  List<Ingredient> ingredients = [];

  Recipe(this.id);

  Recipe.clone(Recipe other): id = other.id {
    copyFrom(other);
  }

  copyFrom(Recipe other){
    //TODO: Add other fields
    this.name = other.name;
    this.description = other.description;
    this.ingredients = other.ingredients.map((ingredient){
      return Ingredient.clone(ingredient);
    }).toList();
  }
}

class Ingredient {

  static const double _tol = 0.05;
  static const List<String> imperialVolume = [
    "C", "tbsp", "tsp", "fl. Oz", "gal"
  ];
  static const List<String> imperialWeight = [
    "Oz", "lb"
  ];
  static const List<String> metricVolume = [
    "mL", "L"
  ];
  static const List<String> metricWeight = [
    "g", "kg"
  ];

  int order;
  String name;
  double amount;
  String unit;
  String comment;

  Ingredient({this.order, this.name, this.amount, this.unit, this.comment});

  Ingredient.clone(Ingredient other){
    this.order = other.order;
    this.name = other.name;
    this.amount = other.amount;
    this.unit = other.unit;
    this.comment = other.comment;
  }

  Ingredient operator *(double mult){
    Ingredient newIngredient = Ingredient.clone(this);
    newIngredient.amount *= mult;
    return newIngredient;
  }

  Ingredient operator /(double div){
    return this * (1 / div);
  }

  bool get isImperial {
    return imperialVolume.contains(normalizedUnit) || imperialWeight.contains(normalizedUnit);
  }

  bool get isMetric {
    return metricVolume.contains(normalizedUnit) || metricWeight.contains(normalizedUnit);
  }

  bool get isVolume {
    return imperialVolume.contains(normalizedUnit) || metricVolume.contains(normalizedUnit);
  }

  bool get isWeight {
    return imperialWeight.contains(normalizedUnit) || metricWeight.contains(normalizedUnit);
  }

  /// Coerces [unit] to be more predictable. For example, converts "Tablespoons",
  /// "tablespoon", "tbsp", and "TbSp" all to "tbsp".
  /// If [unit] corresponds to one of the following, it will be changed:
  ///  - tsp
  ///  - tbsp
  ///  - C
  ///  - P
  ///  - fl. Oz
  ///  - Oz
  ///  - mL
  ///  - L
  ///  - g
  ///  - kg
  String get normalizedUnit {
    switch(unit.toLowerCase().replaceAll(RegExp(r'\.|s$'), "")){
      case "tsp":
      case "teaspoon":
        return "tsp";
      case "tbsp":
      case "tablespoon":
        return "tbsp";
      case "c":
      case "cup":
       return "C";
      case "p":
      case "pint":
        return "P";
      case "fl oz":
      case "fluid oz":
      case "fl ounce":
      case "fluid ounce":
        return "fl. Oz";
      case "oz":
      case "ounce":
      case "ounces":
        return "Oz";
      case "ml":
      case "milliliter":
      case "millilitre":
        return "mL";
      case "l":
      case "liter":
      case "litre":
        return "L";
      case "g":
      case "gram":
        return "g";
      case "kg":
      case "kilogram":
        return "kg";
      default:
        return unit;
    }
  }

  /// Returns a new [Ingredient] object with a new [amount] and [unit], such
  /// that [unit] is one of "mL", "g", or "kg".
  Ingredient get metric {
    Ingredient newIngredient = Ingredient.clone(this);
    switch(normalizedUnit){
      case "tsp":
        newIngredient.amount *= 4.93;
        newIngredient.unit = "mL";
        break;
      case "tbsp":
        newIngredient.amount *= 14.78;
        newIngredient.unit = "mL";
        break;
      case "C":
        newIngredient.amount *= 236.6;
        newIngredient.unit = "mL";
        break;
      case "P":
        newIngredient.amount *= 473.2;
        newIngredient.unit = "mL";
        break;
      case "fl. Oz":
        newIngredient.amount *= 29.57;
        newIngredient.unit = "mL";
        break;
      case "Oz":
        newIngredient.amount *= 28.35;
        newIngredient.unit = "g";
        break;
      case "lb":
        newIngredient.amount *= 0.4536;
        newIngredient.unit = "kg";
    }
    return newIngredient;
  }

  /// Returns a new [Ingredient] object with a new [amount] and [unit], such
  /// that [unit] is one of "C", "oz", or "lb".
  Ingredient get imperial {
    Ingredient newIngredient = Ingredient.clone(this);
    switch(normalizedUnit){
      case "mL":
        newIngredient.amount /= 236.6;
        newIngredient.unit = "C";
        break;
      case "g":
        newIngredient.amount /= 28.35;
        newIngredient.unit = "oz";
        break;
      case "kg":
        newIngredient.amount *= 2.205;
        newIngredient.unit = "lb";
        break;
    }
    return newIngredient;
  }

  /// Returns a string containing the amount and unit of measurement of this
  /// ingredient. It will round the amount to look nice, and if the unit is
  /// not metric, will display it as a nice unicode fraction (if a reasonable
  /// fraction approximation can be found).
  ///
  /// Examples:
  /// `assert(Ingredient(amount: 0.5, unit: "tbsp").display == "1\u{2044}2")`
  /// `assert(Ingredient(amount: 0.3333, unit: "ml").display == "0.33")`
  /// `assert(Ingredient(amount: 101.123, unit: "ml").display == "101")`
  String get display {
    if (["C", "tbsp", "tsp"].contains(normalizedUnit)) {
      String result = "";
      double totalCups;
      switch (normalizedUnit) {
        case "tsp":
          totalCups = amount / 48;
          break;
        case "tbsp":
          totalCups = amount / 16;
          break;
        default:
          totalCups = amount;
      }

      int eighthCups = (totalCups * 8.0).round();
      int tablespoons = (totalCups * 16.0).round();
      int teaspoons = (totalCups * 48.0).round();
      int quarterTeaspoons = (totalCups * 48.0 * 4.0).round();

      if((eighthCups / 8 - totalCups).abs() / totalCups < _tol){

        if(eighthCups > 7) {
          result += "${eighthCups ~/ 8}";
        }

        if(eighthCups % 8 > 0){
          result += " " + showFraction((eighthCups % 8) / 8, binaryDenom: true, unicode: true, maxDenom: 8) + " ";
        }
        result += "C";
      }else if((tablespoons / 16 - totalCups).abs() / totalCups < _tol){
        result += "${tablespoons}tbsp";
      }else if((teaspoons / 48 - totalCups).abs() / totalCups < _tol){
        result += "${teaspoons}tsp";
      }else if((quarterTeaspoons / (48 * 4) - totalCups).abs() / totalCups < _tol){

        if(quarterTeaspoons > 3) {
          result += "${quarterTeaspoons ~/ 4}";
        }

        if(quarterTeaspoons % 4 > 0){
          result += " " + showFraction((quarterTeaspoons % 4) / 4, maxDenom: 4, binaryDenom: true, unicode: true) + " ";
        }
        result += "tsp";
      }else{
        result += sprintf("%.2ftsp", [totalCups * 48.0]);
      }

      return result;

    }else if(isMetric){
      return "${showDecimal(amount)} $unit";
    }else{
      return "${showFraction(amount, unicode: true)} $unit";
    }
  }
}

enum Result {
  deleted,
  created,
  changed,
  unchanged,
}

class RecipeResult {
  final Result result;
  final Recipe recipe;

  RecipeResult(this.result, this.recipe);
}