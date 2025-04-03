import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/screens/recipe_detail_screen.dart';
import 'package:flutter_application_group_project/widgets/recipeDetail/recipe_tile.dart';

import '../database/database.dart';
import '../database/enums/recipe_tag.dart';
import '../widgets/filter/filter_bottom_sheet.dart';

/// A widget to browse and inspect food recipes.
class RecipesBrowse extends StatefulWidget {
  final List<Recipe> llmRecipes;
  final List<Recipe> nameRecipes;
  final List<Recipe> ingredientRecipes;

  const RecipesBrowse(
      {super.key,
      required this.llmRecipes,
      required this.nameRecipes,
      required this.ingredientRecipes});

  @override
  _RecipesBrowseState createState() => _RecipesBrowseState();
}

class _RecipesBrowseState extends State<RecipesBrowse> {
  Map<String, RecipeTag> selectedCategories = {};
  RangeValues selectedRange = const RangeValues(0, 1000);
  List<Recipe> llmRecipesFiltered = [];
  List<Recipe> nameRecipesFiltered = [];
  List<Recipe> ingredientRecipesFiltered = [];

  bool _isInRange(double value) {
    return value >= selectedRange.start && value <= selectedRange.end;
  }

  void _onFilterSubmitted(
      Map<String, RecipeTag> categories, RangeValues range) {
    setState(() {
      selectedCategories = categories;
      selectedRange = range;
      llmRecipesFiltered = widget.llmRecipes
          .where((e) =>
              _isInRange(e.totalCalories) && selectedCategories.isNotEmpty
                  ? e.tags.any((tag) => selectedCategories.containsValue(tag))
                  : true)
          .toList();
      nameRecipesFiltered = widget.nameRecipes
          .where((e) =>
              _isInRange(e.totalCalories) && selectedCategories.isNotEmpty
                  ? e.tags.any((tag) => selectedCategories.containsValue(tag))
                  : true)
          .toList();
      ingredientRecipesFiltered = widget.ingredientRecipes
          .where((e) =>
              _isInRange(e.totalCalories) && selectedCategories.isNotEmpty
                  ? e.tags.any((tag) => selectedCategories.containsValue(tag))
                  : true)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    llmRecipesFiltered = widget.llmRecipes;
    nameRecipesFiltered = widget.nameRecipes;
    ingredientRecipesFiltered = widget.ingredientRecipes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('ผลลัพธ์การค้นหา'),
          actions: [
            // เพิ่มปุ่มที่มุมขวาบนของแอป
            IconButton(
                icon: Icon(Icons.filter_alt, color: theme.iconTheme.color),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return FilterBottomSheet(
                        initCalRange: selectedRange,
                        initSelCategories: selectedCategories,
                        onSubmitted: (categories, range) {
                          _onFilterSubmitted(categories, range);
                        },
                      );
                    },
                  );
                }),
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Divider(),
              if (widget.llmRecipes.isNotEmpty)
                Wrap(
                  children: [
                    ListTile(
                      title: Text('สูตรจาก FoodGuru'),
                      trailing: Text('(${llmRecipesFiltered.length})'),
                    ),
                    SizedBox(height: 15),
                    ...llmRecipesFiltered
                        .map((recipe) => RecipeTile(recipe: recipe))
                  ],
                ),
              if (widget.nameRecipes.isNotEmpty)
                Wrap(
                  children: [
                    ListTile(
                      title: Text('สูตรจากชื่ออาหาร'),
                      trailing: Text('(${nameRecipesFiltered.length})'),
                    ),
                    SizedBox(height: 15),
                    ...nameRecipesFiltered
                        .map((recipe) => RecipeTile(recipe: recipe))
                  ],
                ),
              if (widget.ingredientRecipes.isNotEmpty)
                Wrap(
                  children: [
                    ListTile(
                      title: Text('สูตรจากส่วนผสม'),
                      trailing: Text('(${ingredientRecipesFiltered.length})'),
                    ),
                    SizedBox(height: 15),
                    ...ingredientRecipesFiltered
                        .map((recipe) => RecipeTile(recipe: recipe))
                  ],
                ),
            ],
          ),
        ));
  }
}
