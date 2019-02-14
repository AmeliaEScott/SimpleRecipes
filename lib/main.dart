import 'package:flutter/material.dart';
import 'recipelist.dart';
import 'database.dart';

void main() => runApp(new SimpleRecipes());

class SimpleRecipes extends StatelessWidget {

  final _recipes = Database().getRecipes();

  @override
  Widget build(BuildContext context) {
    var db = Database();
    var query = db.query();

    return new MaterialApp(
      title: 'Simple Recipes',
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Simple Recipes'),
        ),
        body: RecipeList(_recipes),
        //body: Text("AAAAHHHHHH")
      ),
    );
  }
}