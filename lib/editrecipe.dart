import 'package:flutter/material.dart';
import 'recipe.dart';

class EditRecipe extends StatelessWidget{
  final Recipe _recipe;

  EditRecipe(this._recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing recipe"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0
        ),
        child: EditRecipeForm(_recipe),
      )
    );
  }

}

class EditRecipeForm extends StatefulWidget {

  final Recipe _recipe;

  EditRecipeForm(this._recipe);

  @override
  State<StatefulWidget> createState() {
    return _EditRecipeFormState(_recipe);
  }

}

class _EditRecipeFormState extends State<EditRecipeForm>{

  final Recipe _recipe;
  final _formKey = GlobalKey<FormState>();

  _EditRecipeFormState(this._recipe);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        children: [
          TextFormField(
            keyboardType: TextInputType.text,
            initialValue: _recipe.name,
            decoration: InputDecoration(
              labelText: "Recipe Name",
            ),
            validator: (value) => value.isEmpty ? "Must not be empty" : null,
            onSaved: (value) => _recipe.name = value
          ),

          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            initialValue: _recipe.description,
            decoration: InputDecoration(
              labelText: "Description (optional)"
            ),
            onSaved: (value) => _recipe.description = value,
          ),

          _IngredientList(_recipe),

          RaisedButton(
            child: Text("Save"),
            onPressed: (){
              if(_formKey.currentState.validate()){
                _formKey.currentState.save();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Recipe saved"),
                ));
              }else{
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Cannot save recipe")
                ));
              }
            },
          )
        ]
      )
    );
  }
}

class _IngredientList extends StatefulWidget{

  final Recipe _recipe;

  _IngredientList(this._recipe);

  @override
  State<StatefulWidget> createState() {
    return _IngredientListState(_recipe);
  }

}

class _IngredientListState extends State<_IngredientList>{

  final Recipe _recipe;
  List<Ingredient> _ingredients = [];

  _IngredientListState(this._recipe);

  void removeIngredient(Ingredient ingredient){
    setState(() {
      _ingredients.removeWhere((other) => other.order == ingredient.order);
    });
  }

  void addIngredient(){
    setState(() {
      int order = _ingredients.length == 0 ? 1 : _ingredients.last.order + 1;
      _ingredients.add(Ingredient(order: order));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: _ingredients.map(
                  (ingredient) => _IngredientView(ingredient, this)
          ).toList()
        ),
        RaisedButton(
          child: Icon(Icons.add),
          onPressed: this.addIngredient,
        )
      ],
    );
  }
}

class _IngredientView extends StatelessWidget{

  final Ingredient _ingredient;
  final _IngredientListState _state;

  _IngredientView(this._ingredient, this._state);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(_ingredient.order),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: TextFormField(
                  initialValue: _ingredient.name,
                  decoration: InputDecoration(
                      labelText: "Name"
                  ),
                  onSaved: (value) => _ingredient.name = value,
                  validator: (value) => value.isEmpty ? "Required" : null,
                )
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: _ingredient.unit,
                decoration: InputDecoration(
                    labelText: "Unit"
                ),
                onSaved: (value) => _ingredient.unit = value,
                validator: (value) => value.isEmpty ? "Required" : null,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: TextFormField(
                initialValue: _ingredient.comment,
                decoration: InputDecoration(
                    labelText: "Comment (optional)"
                ),
                onSaved: (value) => _ingredient.comment = value,
                validator: (value) => null,
              )
            ),
            Expanded(
              flex: 2,
              child: RaisedButton(
                onPressed: () => _state.removeIngredient(_ingredient),
                child: Icon(Icons.delete),
                color: Colors.red,
              )
            )
          ]
        )
      ]
    );
  }

}