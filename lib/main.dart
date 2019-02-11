import 'package:flutter/material.dart';

void main() => runApp(new SimpleRecipes());

class SimpleRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Simple Recipes',
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Simple Recipes'),
        ),
        body: const Center(
          child: const Text('Hello World'),
        ),
      ),
    );
  }
}