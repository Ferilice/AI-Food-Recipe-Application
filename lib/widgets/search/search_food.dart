import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/helpers/food_guru.dart';
import 'package:flutter_application_group_project/database/local_database.dart';
import 'package:flutter_application_group_project/screens/recipes_browse.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../database/database.dart';

/// A main search bar for searching food recipes with Food Guru integration.
class SearchFood extends StatefulWidget {
  final Function? onGoBack;

  const SearchFood({super.key, this.onGoBack});

  @override
  State<SearchFood> createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _db = LocalDatabase().database;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      onChanged: (text) => setState(() {}),
      focusNode: _focusNode,
      style: GoogleFonts.kanit(
        color: theme.textTheme.bodyMedium!.color,
      ),
      decoration: InputDecoration(
        labelStyle: GoogleFonts.kanit(
          color: theme.textTheme.bodyMedium!.color,
        ),
        labelText: 'ค้นหาด้วยชื่อ/วัตถุดิบ || 🤤 Food Guru',
        border: OutlineInputBorder(),
      ),
      onTapOutside: (pointer) => _focusNode.unfocus(),
      onSubmitted: (value) async {
        await SearchFoodApi.search(context, _controller.text).then((value) {
          if (widget.onGoBack != null) {
            widget.onGoBack!();
          }
        });
      },
    );
  }
}

/// A class with utility functions to search for food recipes.
class SearchFoodApi {
  /// Search local database and Food Guru for recipes and push to [RecipesBrowse] for display.
  static Future<void> search(BuildContext context, String text,
      {Function? onGoBack}) async {
    final _db = LocalDatabase().database;
    try {
      _loadingDialog(context);
      await _db.into(_db.searchs).insert(SearchsCompanion.insert(
            content: text,
          ));
      final llmGeneratedRecipes = await FoodGuru().findRecipes(text);
      final fromNameRecipes = await (_db.select(_db.recipes)
            ..where((e) => e.name.contains(text)))
          .get();
      final fromIngredientsRecipes = await (_db.select(_db.recipes)
            ..where((e) => e.ingredients.contains(text)))
          .get();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipesBrowse(
            llmRecipes: llmGeneratedRecipes,
            nameRecipes: fromNameRecipes,
            ingredientRecipes: fromIngredientsRecipes,
          ),
        ),
      ).then((value) {
        if (onGoBack != null) {
          onGoBack();
        }
      });
    } catch (e) {
      Navigator.pop(context);
      _errorDialog(context);
      print(e);
    }
  }
}

void _loadingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('กำลังโหลดข้อมูล...'),
          ],
        ),
      );
    },
  );
}

void _errorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text('ไม่สามารถเชื่อมต่อกับ Food Guru ได้'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด'),
          ),
        ],
      );
    },
  );
}
