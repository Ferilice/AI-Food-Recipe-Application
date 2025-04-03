import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../screens/recipe_detail_screen.dart';

/// A tile that displays a recipe in [RecipesBrowse]
class RecipeTile extends StatelessWidget {
  final Recipe recipe;

  const RecipeTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: Image.asset(recipe.imagePath,
            width: 50, // Adjust the width and height as needed
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) =>
                Image.asset('assets/images/food_placeholder.png')),
      ),
      title: Text(recipe.name),
      // trailing: Text(recipe.tags.join(', ')),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
    );
  }
}
