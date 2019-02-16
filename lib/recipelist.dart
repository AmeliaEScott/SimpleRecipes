import 'package:flutter/material.dart';
import 'recipe.dart';
import 'editrecipe.dart';

class RecipeList extends StatelessWidget {

  final Future<List<Recipe>> _recipes;

  RecipeList(this._recipes);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _recipes,
      builder: (context, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return CircularProgressIndicator(value: null);
          case ConnectionState.done:
            //TODO: Handle error
            List<Recipe> recipes = snapshot.data;
            return ListView.separated(
              itemCount: recipes.length,
                itemBuilder: (context, index) => _RecipeListElement(recipes[index]),
                separatorBuilder: (context, index) => Divider()
            );
        }
      },
    );
  }
}

class _RecipeListElement extends StatelessWidget {

  final Recipe _recipe;

  _RecipeListElement(this._recipe);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
        return EditRecipe(_recipe);
      })),
      child: ListTile(
        //TODO: Populate with recipe info
        title: Text(_recipe.name),
        subtitle: Text(_recipe.description),
      ),
    );
  }

}
