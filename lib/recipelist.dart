import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipeview.dart';

/// Shows the list of recipes. Allows the user
/// to tap individual recipes to view and edit them.
class RecipeList extends StatefulWidget {

  final Future<List<Recipe>> _recipes;
  
  RecipeList(this._recipes);

  @override
  State<StatefulWidget> createState() {
    return _RecipeListState();
  }

}

class _RecipeListState extends State<RecipeList>{

  List<Recipe> _recipes;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget._recipes,
      builder: (context, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return CircularProgressIndicator(value: null);
          case ConnectionState.done:
          //TODO: Handle error
            _recipes = snapshot.data;
            return ListView.separated(
                itemCount: _recipes.length,
                itemBuilder: (context, index) => _RecipeListElement(_recipes[index], onTap),
                separatorBuilder: (context, index) => Divider()
            );
        }
      },
    );
  }

  /// Callback function for when an individual recipe is tapped.
  /// This function navigates to the RecipeView for that individual recipe,
  /// and then handles changes made to that recipe by calling setState()
  /// if necessary.
  void onTap(Recipe recipe){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      // Passing this recipe to the RecipeView could result in it being changed.
      // (It's a mutable object, passed by reference)
      return RecipeView(recipe);
      // So, to handle this possibility, and update the recipe information
      // in the UI, I need to call setState() somehow when this route returns.
      // (See a few lines below)
    })).then((result) {
      if(result != null && result is RecipeResult && result.result == Result.deleted){
        removeRecipe(recipe);
      }else{
        // Just assume that it changed, because rebuilding this whole list
        // probably won't be too processor-intensive.
        // TODO: Only set the state of the specific _RecipeListElement, to
        // avoid rebuilding the whole list.
        setState((){});
      }
    });
  }

  /// Removes one recipe from the list, and rebuilds the list to reflect
  /// this change in the UI.
  ///
  /// (This function does call setState())
  void removeRecipe(Recipe toRemove){
    setState(() {
      _recipes.removeWhere((recipe) => recipe == toRemove);
    });
  }
}

class _RecipeListElement extends StatelessWidget {

  final Recipe _recipe;
  final void Function(Recipe) _onTap;

  /// [_onTap] will be called when this recipe is tapped, with [_recipe]
  /// passed to it as the argument.
  _RecipeListElement(this._recipe, this._onTap);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => _onTap(_recipe),
      child: ListTile(
        //TODO: Populate with recipe info (Like image, categories, IDK)
        title: Text(_recipe.name),
        subtitle: Text(_recipe.description),
      ),
    );
  }

}
