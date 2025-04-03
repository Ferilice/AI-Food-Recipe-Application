import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/database/local_database.dart';

import '../database/database.dart';

/// A widget to configure, browse and inspect food recipes in the database.
class DatabaseBrowse extends StatelessWidget {
  final _db = LocalDatabase().database;

  Future<List<Recipe>> getRecipes() async {
    final result = await _db.select(_db.recipes).get();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ฐานข้อมูล'),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('ล้างข้อมูลจาก FoodGuru'),
                    value: 'clearFoodGuru',
                    onTap: () async {
                      final query = _db.delete(_db.recipes)..where((e) => e.isLlmGenerated.equals(true));
                      await query.go();
                    },
                  ),
                ];
              },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final recipes = snapshot.data!;
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  debugPrint(recipe.name);
                  return ListTile(
                    leading: Text(recipe.id.toString()),
                    title: Text(recipe.name),
                    trailing: recipe.isLlmGenerated ? Icon(Icons.smart_toy) : Icon(Icons.import_contacts),
                  );
                },
              );
            } else if (snapshot.hasError) {
              debugPrint('Error: ${snapshot.error}');
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }
            else {
              return Center(child: Text('ไม่พบข้อมูล'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
