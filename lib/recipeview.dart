import 'package:flutter/material.dart';
import 'recipe.dart';
import 'editrecipe.dart';
import 'util.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

    List<Widget> children = [
      Text(
        _recipe.name,
        style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 2.0,
      ),
      Text(
        _recipe.description
      ),
      Divider(),
      Text(
        "Ingredients",
        style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 2.0,
      ),
    ];

    children.addAll(_recipe.ingredients.map((ingredient){
      String title;
      ingredient *= multiple;
      if(conversion == PopupOptions.metric){
        title = ingredient.metric.display;
      }else if(conversion == PopupOptions.imperial){
        title = ingredient.imperial.display;
      }else{
        title = ingredient.display;
      }

      Widget child = Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                title,
                textAlign: TextAlign.end,
              ),
            )
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                ingredient.name,
                textAlign: TextAlign.start,
              ),
            )
          )
        ],
      );

      if(ingredient.comment.isNotEmpty){
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            child,
            Row(
              children: <Widget>[
                Spacer(flex: 3),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                    child: Text(
                      ingredient.comment,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textScaleFactor: 0.9,
                    )
                  )
                )
              ]

            ),

          ],
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 3.0),
        child: child,
      );
    }));

    children.add(Divider());

    children.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            "Procedure",
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
            textScaleFactor: 2.0,
          ),
        )

    );

    children.add(
      MarkdownBody(
        data: """
# PART 1

This is some nice markdown!

 1. First item on list
 2. Second item on list
 3. *now* we're getting **FANCY**!
        """
      )
    );

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
      body: ListView(
        children: children,
      )
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