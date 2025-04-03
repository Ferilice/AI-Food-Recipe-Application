// 640510612 Natchanon Jina
// 640510675 Poomiputh Boonma

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'enums/recipe_tag.dart';

part 'database.g.dart';

class Ingredient {
  String name;
  double quantity;
  String unit;
  bool isOptional;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isOptional,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      isOptional: json['is_optional'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'is_optional': isOptional,
    };
  }
}

class IngredientsConverter extends TypeConverter<List<Ingredient>, String> {
  const IngredientsConverter();

  @override
  List<Ingredient> fromSql(String fromDb) {
    return (fromDb.split(';')).map((e) {
      final parts = e.split(',');
      return Ingredient(
        name: parts[0],
        quantity: double.parse(parts[1]),
        unit: parts[2],
        isOptional: parts[3] == 'true',
      );
    }).toList();
  }

  @override
  String toSql(List<Ingredient> value) {
    return value.map((e) {
      return '${e.name},${e.quantity},${e.unit},${e.isOptional}';
    }).join(';');
  }
}

class InstructionsConverter extends TypeConverter<List<String>, String> {
  const InstructionsConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.split(';');
  }

  @override
  String toSql(List<String> value) {
    return value.join(';');
  }
}

class TagsConverter extends TypeConverter<List<RecipeTag>, String> {
  const TagsConverter();

  @override
  List<RecipeTag> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return [];
    }
    try {
      return fromDb.split(';').map((e) => RecipeTag.values[int.parse(e)]).toList();
    } catch (e) {
      print('Error parsing tags: $fromDb');
      rethrow;
    }
  }

  @override
  String toSql(List<RecipeTag> value) {
    if (value.isEmpty) {
      return '';
    }
    return value.map((e) => e.index.toString()).join(';');
  }
}

class Recipe {
  int id;
  String name;
  String description;
  List<Ingredient> ingredients;
  List<String> instructions;
  double totalCalories;
  String imagePath;
  bool isLlmGenerated;
  List<RecipeTag> tags;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.totalCalories,
    required this.imagePath,
    required this.isLlmGenerated,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: (json['ingredients'] as List)
          .map((e) => Ingredient.fromJson(e))
          .toList(),
      instructions: (json['instructions'] as List).cast<String>(),
      totalCalories: (json['total_calories'] as num).toDouble(),
      imagePath: json['image_path'],
      isLlmGenerated: json['is_llm_generated'],
      tags: (json['tags'] as List)
          .map((e) => RecipeTag.values[(e as num).toInt()])
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'total_calories': totalCalories,
      'image_path': imagePath,
      'is_llm_generated': isLlmGenerated,
      'tags': tags.map((e) => e.index).toList(),
    };
  }
}

@UseRowClass(Recipe)
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get description => text().withLength(min: 1, max: 200)();

  TextColumn get ingredients => text().map(const IngredientsConverter())();

  TextColumn get instructions => text().map(const InstructionsConverter())();

  RealColumn get totalCalories => real()();

  TextColumn get imagePath => text()();

  BoolColumn get isLlmGenerated => boolean().withDefault(Constant(false))();

  TextColumn get tags => text().map(const TagsConverter())();
}

class Tobuys extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  BoolColumn get isCompleted => boolean().withDefault(Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get description => text().withLength(min: 0, max: 200)();
}

@TableIndex(name: 'bookmark_recipe', columns: {#bookmarkId, #recipeId})
class BookmarkRecipes extends Table {
  IntColumn get id => integer().autoIncrement()();

  @ReferenceName('bookmark')
  IntColumn get bookmarkId =>
      integer().references(Bookmarks, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('recipe')
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
}

class Searchs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get content => text().withLength(min: 1, max: 200)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Recipes, Tobuys, Bookmarks, BookmarkRecipes, Searchs])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(beforeOpen: (openingDetails) async {
        if (true /* or some other flag */) {
          final m = createMigrator(); // changed to this
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
            await m.createTable(table);
          }

          await m.createAll();

          String jsonString = await rootBundle.loadString('assets/meals.json');
          final jsonResult = jsonDecode(jsonString)['meals'];
          for (final meal in jsonResult) {
            final tempRecipe = Recipe.fromJson(meal);
            int id = await into(recipes).insert(RecipesCompanion.insert(
              name: tempRecipe.name,
              description: tempRecipe.description,
              ingredients: tempRecipe.ingredients,
              instructions: tempRecipe.instructions,
              totalCalories: tempRecipe.totalCalories,
              imagePath: tempRecipe.imagePath,
              tags: tempRecipe.tags,
            ));
            print('Inserted recipe with id: $id');
            print('${tempRecipe.name} ${tempRecipe.tags}');
          }
        }
      });

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
