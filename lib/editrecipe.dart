import 'package:flutter/material.dart';
import 'recipe.dart';
import 'util.dart';

class EditRecipe extends StatelessWidget {
  final Recipe _recipe;

  //EditRecipe(Recipe recipe): _recipe = Recipe.clone(recipe);
  EditRecipe(this._recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing recipe"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              // TODO: Ask for confirmation with an AlertDialog
              Navigator.pop(context, RecipeResult(Result.deleted, _recipe));
            },
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: EditRecipeForm(_recipe)),
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

class _EditRecipeFormState extends State<EditRecipeForm> {
  // _originalRecipe is a reference to the original Recipe object passed to
  // this route. Any changes in it are automatically reflected in the other
  // routes that came before this one.
  Recipe _originalRecipe;
  // _recipe is a temporary deep copy of _originalRecipe. _recipe can be
  // altered with reckless abandon, because changes to _recipe will not be
  // reflected anywhere else, unless they are first copied into _originalRecipe.
  Recipe _recipe;
  final _formKey = GlobalKey<FormState>();

  //_EditRecipeFormState(this._oldRecipe): _newRecipe = Recipe.clone(_oldRecipe);
  _EditRecipeFormState(this._originalRecipe)
      : _recipe = Recipe.clone(_originalRecipe);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Form(
            key: _formKey,
            // Every change to a text box is immediately copied to _recipe
            // The recipe can be finally, /actually/ saved by copying _recipe
            // into _originalRecipe
            onChanged: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
              }
            },
            child: ListView(children: [
              TextFormField(
                keyboardType: TextInputType.text,
                initialValue: _recipe.name,
                decoration: InputDecoration(
                  labelText: "Recipe Name",
                ),
                validator: (value) =>
                    value.isEmpty ? "Must not be empty" : null,
                onSaved: (value) => _recipe.name = value,
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                initialValue: _recipe.description,
                decoration:
                    InputDecoration(labelText: "Description (optional)"),
                onSaved: (value) => _recipe.description = value,
              ),
              _IngredientList(_recipe, _formKey),
            ])));
  }

  // Called when the back button is pressed. Shows an AlertDialog to ask
  // if the user wants to save their changes.
  Future<bool> onWillPop(context) async {
    if(_formKey.currentState.validate()) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text("Save changes?"), actions: [
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  //TODO: Handle saving to database
                  _originalRecipe.copyFrom(_recipe);
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text("Discard"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ]);
          });
    }else{
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text("Some changes could not be saved."), actions: [
              FlatButton(
                child: Text("Discard"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ]);
          });
    }
  }
}

class _IngredientList extends StatefulWidget {
  final Recipe _recipe;
  final GlobalKey<FormState> _formKey;

  _IngredientList(this._recipe, this._formKey);

  @override
  State<StatefulWidget> createState() {
    return _IngredientListState(_recipe, _formKey);
  }
}

class _IngredientListState extends State<_IngredientList> {
  final Recipe _recipe;
  final GlobalKey<FormState> _formKey;

  _IngredientListState(this._recipe, this._formKey);

  void removeIngredient(Ingredient ingredient) {
    setState(() {
      _recipe.ingredients
          .removeWhere((other) => other.order == ingredient.order);
    });
  }

  void addIngredient() {
    setState(() {
      int order = _recipe.ingredients.length == 0
          ? 1
          : _recipe.ingredients.last.order + 1;
      _recipe.ingredients.add(Ingredient(order: order));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
            children: _recipe.ingredients
                .map((ingredient) => _IngredientView(ingredient, this))
                .toList()),
        RaisedButton(
          child: Icon(Icons.add),
          onPressed: this.addIngredient,
        )
      ],
    );
  }
}

class _IngredientView extends StatelessWidget {
  final Ingredient _ingredient;
  final _IngredientListState _state;

  _IngredientView(this._ingredient, this._state);

  @override
  Widget build(BuildContext context) {
    return Column(key: ValueKey(_ingredient.order), children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              flex: 8,
              child: TextFormField(
                initialValue: _ingredient.name,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                onSaved: (value) => _ingredient.name = value,
                validator: (value) => value.isEmpty ? "Required" : null,
              )),
          Expanded(
              flex: 4,
              child: TextFormField(
                initialValue:
                    _ingredient.amount == null ? "" : showFraction(_ingredient.amount),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Amount",
                ),
                onSaved: (value) => _ingredient.amount = parseFraction(value) ?? 0,
                validator: (value) => parseFraction(value) == null ? "Not a number" : null,
              )),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: _ingredient.unit,
              decoration: InputDecoration(labelText: "Unit"),
              onSaved: (value) => _ingredient.unit = value ?? "",
            ),
          ),
        ],
      ),
      Row(children: <Widget>[
        Expanded(
            flex: 17,
            child: TextFormField(
              initialValue: _ingredient.comment,
              decoration: InputDecoration(labelText: "Comment (optional)"),
              onSaved: (value) => _ingredient.comment = value,
              validator: (value) => null,
            )),
        Expanded(
            flex: 3,
            child: RaisedButton(
              onPressed: () => _state.removeIngredient(_ingredient),
              child: Icon(Icons.delete),
              color: Colors.red,
            ))
      ])
    ]);
  }
}
