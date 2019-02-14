import 'recipe.dart';
import 'dart:async';
import 'dart:math';

class Database {
  Database();

  Future<Query> query() async{
    var query = Query();
    await query.init();
    return query;
  }

  Future<List<Recipe>> getRecipes() async {
    await Future.delayed(Duration(milliseconds: 5000));
    return List.generate(100, (index) => Recipe(index));
  }
}

//TODO: Delete this entirely
class Query {
  static const int _PAGE_SIZE = 10;

  int count = 0;

  Map<int, Recipe> _cache = {};
  //TODO: Change type to `Future<...>` or whatever the data type is for SQL queries
  Map<int, Future> _waiting = {};

  Query();

  Future init() async {
    await Future.delayed(Duration(milliseconds: 1000));
    count = Random().nextInt(60) + 70;
  }

  Future<Recipe> operator [](int index) async {
    if(index >= count){
      return null;
    }else if(_cache.containsKey(index)){
      return _cache[index];
    }

    int page = (index ~/ _PAGE_SIZE);
    if(!_waiting.containsKey(page)) {
      var completer = Completer();
      _waiting[page] = completer.future;
      // TODO: Do the SQL query here
      await Future.delayed(Duration(milliseconds: 1000));
      // TODO: Unpack the SQL query here and add it to the cache
      for(int i = page * _PAGE_SIZE; i < (page + 1) * _PAGE_SIZE; i++){
        _cache[i] = Recipe(i);
      }
      completer.complete();
    }else{
      await _waiting[page];
    }

    return _cache[index];

  }
}