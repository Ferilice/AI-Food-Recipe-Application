// 640510646 Jedsadaporn Nedpab
// 640510675 Poomiputh Boonma

import 'package:flutter/cupertino.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../database/local_database.dart';

/// A widget that manages the bookmark checkbox inside [RecipesBrowse]'s bookmark action.
class BookmarkCheckbox extends StatefulWidget {
  final Recipe recipe;
  final (Bookmark, $$BookmarksTableReferences) bookmarkAndRef;
  final Function? onChanged;

  const BookmarkCheckbox(
      {super.key,
      required this.recipe,
      required this.bookmarkAndRef,
      this.onChanged});

  @override
  _BookmarkCheckboxState createState() => _BookmarkCheckboxState();
}

class _BookmarkCheckboxState extends State<BookmarkCheckbox> {
  late bool isChecked;
  final _db = LocalDatabase().database;

  @override
  void initState() {
    super.initState();
    isChecked = widget.bookmarkAndRef.$2.bookmark.prefetchedData!
        .any((element) => element.recipeId == widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: isChecked,
        onChanged: (bool? value) async {
          if (value == true) {
            // -1 = llm generated
            if (widget.recipe.id == -1) {
              final newRecipeId = await _db
                  .into(_db.recipes)
                  .insert(RecipesCompanion(
                    name: drift.Value(widget.recipe.name),
                    description: drift.Value(widget.recipe.description),
                    ingredients: drift.Value(widget.recipe.ingredients),
                    instructions: drift.Value(widget.recipe.instructions),
                    imagePath: drift.Value(widget.recipe.imagePath),
                    totalCalories: drift.Value(widget.recipe.totalCalories),
                    isLlmGenerated: drift.Value(widget.recipe.isLlmGenerated),
                  ));
              await _db
                  .into(_db.bookmarkRecipes)
                  .insert(BookmarkRecipesCompanion(
                    bookmarkId: drift.Value(widget.bookmarkAndRef.$1.id),
                    recipeId: drift.Value(newRecipeId),
                  ));
            } else {
              await _db
                  .into(_db.bookmarkRecipes)
                  .insert(BookmarkRecipesCompanion(
                    bookmarkId: drift.Value(widget.bookmarkAndRef.$1.id),
                    recipeId: drift.Value(widget.recipe.id),
                  ));
            }
          } else {
            (_db.delete(_db.bookmarkRecipes)
                  ..where((tbl) => tbl.id.equals(widget
                      .bookmarkAndRef.$2.bookmark.prefetchedData!
                      .firstWhere(
                          (element) => element.recipeId == widget.recipe.id)
                      .id)))
                .go();
          }
          setState(() {
            isChecked = value!;
          });
          widget.onChanged?.call(value);
        });
  }
}
