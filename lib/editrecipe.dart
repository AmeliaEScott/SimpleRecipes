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
      body: EditRecipeForm(_recipe),
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
      child: Column(
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
            decoration: InputDecoration(
              labelText: "Description (optional)"
            ),
            onSaved: (value) => _recipe.description = value,
          ),

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