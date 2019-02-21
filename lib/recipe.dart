import 'package:sprintf/sprintf.dart';
import 'package:flutter/foundation.dart';

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

  @override
  bool operator ==(dynamic other){
    if(other is Recipe){
      return other.id == id;
    }else{
      return false;
    }
  }

  @override
  int get hashCode => id;
}

class Ingredient {

  static const double _tol = 0.05;

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

  String get normalizedUnit {
    return unit.toLowerCase().replaceAll(RegExp(r'\.|s$'), "");
  }

  Ingredient get metric {
    Ingredient newIngredient = Ingredient.clone(this);
    switch(normalizedUnit){
      case "tsp":
      case "teaspoon":
        newIngredient.amount *= 4.93;
        newIngredient.unit = "mL";
        break;
      case "tbsp":
      case "tablespoon":
        newIngredient.amount *= 14.78;
        newIngredient.unit = "mL";
        break;
      case "c":
      case "cup":
        newIngredient.amount *= 236.6;
        newIngredient.unit = "mL";
        break;
      case "p":
      case "pint":
        newIngredient.amount *= 473.2;
        newIngredient.unit = "mL";
        break;
      case "fl oz":
      case "fluid oz":
      case "fl ounce":
      case "fluid ounce":
        newIngredient.amount *= 29.57;
        newIngredient.unit = "mL";
        break;
      case "oz":
      case "ounce":
      case "ounces":
        newIngredient.amount *= 28.35;
        newIngredient.unit = "g";
        break;
    }
    return newIngredient;
  }

  Ingredient get imperial {
    Ingredient newIngredient = Ingredient.clone(this);
    switch(normalizedUnit){
      case "ml":
      case "milliliter":
      case "millilitre":
        newIngredient.amount /= 236.6;
        newIngredient.unit = "C";
        break;
      case "g":
      case "gram":
        newIngredient.amount /= 28.35;
        newIngredient.unit = "oz";
        break;
    }
    return newIngredient;
  }

  String get display {
    if (["c", "cup", "tbsp", "tablespoon", "tsp", "teaspoon"].contains(
        normalizedUnit)) {
      String result = "";
      double totalCups;
      switch (normalizedUnit) {
        case "tsp":
        case "teaspoon":
          totalCups = amount / 48;
          break;
        case "tbsp":
        case "tablespoon":
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

        switch(eighthCups % 8){
          case 1:
            result += "\u{215B}";
            break;
          case 2:
            result += "\u{BC}";
            break;
          case 3:
            result += "\u{215C}";
            break;
          case 4:
            result += "\u{BD}";
            break;
          case 5:
            result += "\u{215D}";
            break;
          case 6:
            result += "\u{BE}";
            break;
          case 7:
            result += "\u{215E}";
            break;
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

        switch(quarterTeaspoons % 4){
          case 1:
            result += "\u{BC}";
            break;
          case 2:
            result += "\u{BD}";
            break;
          case 3:
            result += "\u{BE}";
        }
        result += "tsp";
      }else{
        result += sprintf("%.2ftsp", [totalCups * 48.0]);
      }

      result += " " + name;

      debugPrint("Ingredient '$name': $eighthCups qC, $tablespoons tbsp, $teaspoons tsp, $quarterTeaspoons qtsp");

      return result;
    } else {
      //TODO: Figure out precision better
      //int precision = min(-(log(amount) / log(10)) + 2, 0.0).ceil();
      int precision = 2;
      return sprintf("%.${precision}f %s %s", [amount, unit, name]);
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