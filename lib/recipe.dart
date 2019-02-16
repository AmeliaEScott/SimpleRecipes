
class Recipe {
  final int id;

  String name = "";
  String description = "";

  List<Ingredient> ingredients = [];

  Recipe(this.id);
}

class Ingredient {

  int order;
  String name;
  double amount;
  String unit;
  String comment;

  Ingredient({this.order, this.name, this.amount, this.unit, this.comment});

}