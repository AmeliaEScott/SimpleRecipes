
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
  int hashCode() => id;
}

class Ingredient {

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