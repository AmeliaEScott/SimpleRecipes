import 'package:flutter/material.dart';
import 'recipe.dart';
import 'editrecipe.dart';

/// A recipe view handles viewing the details of a single recipe.
/// This recipe CAN be edited, so if you navigate to this route,
/// you should be prepared to handle changes.
///
/// If this recipe gets deleted, then a [RecipeResult] is returned from this
/// route, with result = [Result.deleted]
class RecipeView extends StatefulWidget{

  final Recipe _recipe;

  RecipeView(this._recipe);

  @override
  State<StatefulWidget> createState() {
    return _RecipeViewState(_recipe);
  }
}

class _RecipeViewState extends State<RecipeView>{

  Recipe _recipe;

  _RecipeViewState(this._recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                debugPrint("Opening EditRecipe for recipe #${_recipe.id}");
                return EditRecipe(_recipe);
              })).then((result){
                if(result != null && result is RecipeResult && result.result == Result.deleted){
                  Navigator.pop(context, result);
                }else {
                  // Assume that _recipe changed, because rebuilding this page is
                  // probably not too resource-intensive
                  setState(() {});
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              //TODO: Use AlertDialog to ask for confirmation
              Navigator.pop(context, RecipeResult(Result.deleted, _recipe));
            },
          )
        ],
      ),
      //TODO: Actually fill this with information
      body: Column(
        children: <Widget>[
          Text("Recipe #${_recipe.id}"),
          Text("Name: ${_recipe.name}"),
          Text("Description: ${_recipe.description}"),
          Text("Number of ingredients: ${_recipe.ingredients.length}")
        ],
      ),
    );
  }

}