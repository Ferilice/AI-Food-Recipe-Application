import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/database/local_database.dart';

import '../../database/database.dart';
import '../../widgets/recipeDetail/recipe_tile.dart';

/// A widget that displays the details(Saved recipes) of a bookmark.
class BookmarkDetailScreen extends StatelessWidget {
  final Bookmark bookmark;

  const BookmarkDetailScreen({Key? key, required this.bookmark})
      : super(key: key);

  Future<List<Recipe>> getAllRecipesInBookmark() async {
    final _db = LocalDatabase().database;
    final data = await _db.managers.bookmarkRecipes
        .filter((f) => f.bookmarkId.id(bookmark.id))
        .withReferences((prefetch) => prefetch(recipeId: true))
        .get();
    return data.map((e) => e.$2.recipeId.prefetchedData!.first).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(bookmark.name),
        ),
        body: FutureBuilder(
            future: getAllRecipesInBookmark(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<Widget> recipeTiles = [];
                  for (var recipe in snapshot.data as List<Recipe>) {
                    recipeTiles.add(RecipeTile(recipe: recipe));
                  }
                  return ListView(
                    children: recipeTiles,
                  );
                } else {
                  return Center(
                    child: Text('ยังไม่มีสูตรอาหารในบันทึกนี้'),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
