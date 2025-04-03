import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../database/database.dart';

/// A class with preconfigured GeminiProvider and utilities for food recommendation.
class FoodGuru {
  final _provider = GeminiProvider(
    model: GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyCVljJciLGLtPArrh-LSPIWq2qLOCi9KWI',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          properties: {
            'conversation_text': Schema(
              description: '''
                          Your reason for recommending the recipe to the user.
                           ''',
              SchemaType.string,
            ),
            'recipe': Schema(
              SchemaType.object,
              properties: {
                'id': Schema(
                  SchemaType.number,
                  description: 'Always put -1 in this field.',
                ),
                'name': Schema(SchemaType.string),
                'description': Schema(SchemaType.string),
                'ingredients': Schema(
                  SchemaType.array,
                  items: Schema(SchemaType.object, properties: {
                    'name': Schema(SchemaType.string),
                    'quantity': Schema(SchemaType.number),
                    'unit': Schema(SchemaType.string),
                    'is_optional': Schema(
                      SchemaType.boolean,
                      description: 'Whether the ingredient is optional.',
                    ),
                  }),
                ),
                'instructions': Schema(
                  SchemaType.array,
                  items: Schema(SchemaType.string),
                  description:
                      'Always do not include leading numbers in the instructions.',
                ),
                'total_calories': Schema(SchemaType.number),
                'image_path': Schema(SchemaType.string,
                    description: 'Always put "" in this field.'),
                'is_llm_generated': Schema(
                  SchemaType.boolean,
                  description: 'Always put True in this field.',
                ),
                'tags': Schema(
                  SchemaType.array,
                  items: Schema(SchemaType.integer),
                  description: 'Always put [] in this field.',
                ),
              },
            ),
          },
        ),
      ),
      systemInstruction: Content.system('''
          You are an assistant to help recommend food 
          recipes based on user's ingredients.
          If user provides food names, just find the recipe.
          Prioritize Thai food recipes.
          Respond in Thai language.
          '''),
    ),
  );

  GeminiProvider get provider => _provider;

  /// Find and return a recipe given keyword using the GeminiProvider.
  Future<Recipe> findRecipe(String text) async {
    final stream = _provider.sendMessageStream(text);
    final response = await stream.join();
    final json = jsonDecode(response);
    debugPrint(json['recipe'].toString(), wrapWidth: 1024);
    return Recipe.fromJson(json['recipe']);
  }

  /// Find and return a list of recipes given keyword using the GeminiProvider.
  Future<List<Recipe>> findRecipes(String text) async {
    final result = await findRecipe(text);
    return [result];
  }
}
