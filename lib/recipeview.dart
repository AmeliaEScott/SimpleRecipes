import 'package:flutter/material.dart';
import 'recipe.dart';
import 'editrecipe.dart';
import 'util.dart';

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

enum PopupOptions {
  metric, imperial, none, multiply, delete
}

class _RecipeViewState extends State<RecipeView>{

  Recipe _recipe;
  double multiple = 1.0;
  PopupOptions conversion = PopupOptions.none;

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
          PopupMenuButton<PopupOptions>(
            onSelected: (option){setState((){
              switch(option){
                case PopupOptions.none:
                  conversion = PopupOptions.none;
                  break;
                case PopupOptions.metric:
                  conversion = PopupOptions.metric;
                  break;
                case PopupOptions.imperial:
                  conversion = PopupOptions.imperial;
                  break;
                case PopupOptions.multiply:
                  showDialog(
                    context: context,
                    builder: (context) => _MultiplyDialog(multiple)
                  ).then((newMultiple){
                    if(newMultiple != null){
                      setState(() {
                        multiple = newMultiple;
                      });
                    }
                  });
                  break;
                case PopupOptions.delete:
                  // TODO: Ask for confirmation with AlertDialog
                  Navigator.pop(context, RecipeResult(Result.deleted, _recipe));
              }
            });},
            itemBuilder: (context){
              return <PopupMenuEntry<PopupOptions>>[
                PopupMenuItem(
                  value: PopupOptions.none,
                  child: Text("Disable unit conversion"),
                ),
                PopupMenuItem(
                  value: PopupOptions.metric,
                  child: Text("Convert to metric"),
                ),
                PopupMenuItem(
                  value: PopupOptions.imperial,
                  child: Text("Convert to imperial"),
                ),
                PopupMenuItem(
                  value: PopupOptions.multiply,
                  child: Text("Multiply recipe"),
                ),
                PopupMenuItem(
                  value: PopupOptions.delete,
                  child: Text("Delete recipe")
                ),
              ];
            }
          )
        ],
      ),
      //TODO: Actually fill this with information
      body: Column(
        children: <Widget>[
          Text("Recipe #${_recipe.id}"),
          Text("Name: ${_recipe.name}"),
          Text("Description: ${_recipe.description}"),
          Text("Number of ingredients: ${_recipe.ingredients.length}"),
          Expanded(
            child: ListView(
              children: _recipe.ingredients.map((ingredient){
                ingredient *= multiple;
                if(conversion == PopupOptions.imperial){
                  ingredient = ingredient.imperial;
                }else if(conversion == PopupOptions.metric){
                  ingredient = ingredient.metric;
                }

                return Text(ingredient.display);
              }).toList(),
            )
          )
        ],
      ),
    );
  }

}

class _MultiplyDialog extends StatefulWidget{

  final double multiple;

  _MultiplyDialog(this.multiple);

  @override
  State<StatefulWidget> createState() {
    return _MultiplyDialogState(multiple);
  }

}

class _MultiplyDialogState extends State<_MultiplyDialog>{
  final _formKey = GlobalKey<FormState>();
  double multiple = 1.0;

  _MultiplyDialogState(this.multiple);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      content: Form(
        key: _formKey,
        autovalidate: true,
        child: TextFormField(
          initialValue: showFraction(multiple),
          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
          validator: (value) => parseFraction(value) == null ? "Not a valid number" : null,
          onSaved: (value) => multiple = parseFraction(value),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Confirm"),
          onPressed: (){
            if(_formKey.currentState.validate()){
              _formKey.currentState.save();
              Navigator.pop(context, multiple);
            }
          },
        ),
      ],
    );
  }

}