import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/database/local_database.dart';
import 'package:flutter_application_group_project/screens/recipes_browse.dart';
import 'package:flutter_application_group_project/widgets/recipe_card.dart';
import 'package:flutter_application_group_project/widgets/search/search_food.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';

/// A startup widget for the application.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = LocalDatabase().database;
  late Future<List<Recipe>> randomRecipes;
  late Future<List<Search>> recentSearch;

  Future<List<Recipe>> getRandomRecipes() async {
    final result = await (_db.select(_db.recipes)..limit(4)).get();
    return result;
  }

  Future<List<Search>> getRecentSearch() async {
    final query = _db.select(_db.searchs)
      ..limit(3)
      ..orderBy([(e) => drift.OrderingTerm.desc(e.createdAt)]);
    final result = await query.get();
    return result;
  }

  void onSearchGoBack() {
    setState(() {
      recentSearch = getRecentSearch();
    });
  }

  @override
  void initState() {
    super.initState();
    randomRecipes = getRandomRecipes();
    recentSearch = getRecentSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'หน้าแรก',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SearchFood(
                  onGoBack: onSearchGoBack,
                ),
              ),
              SizedBox(height: 20),
              // เมนูมาแรงวันนี้
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'เมนูแนะนำ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final allRecipes = await _db.select(_db.recipes).get();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipesBrowse(
                              llmRecipes: [],
                              nameRecipes: allRecipes,
                              ingredientRecipes: [],
                            ),
                          ));
                    },
                    child: Text(
                      'ดูทั้งหมด',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              FutureBuilder(
                  future: randomRecipes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final randomRecipe = snapshot.data!;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                randomRecipe.elementAtOrNull(0) != null
                                    ? RecipeCard(
                                        recipe: randomRecipe.elementAt(0))
                                    : Container(),
                                randomRecipe.elementAtOrNull(1) != null
                                    ? RecipeCard(
                                        recipe: randomRecipe.elementAt(1))
                                    : Container(),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                randomRecipe.elementAtOrNull(2) != null
                                    ? RecipeCard(
                                        recipe: randomRecipe.elementAt(2))
                                    : Container(),
                                randomRecipe.elementAtOrNull(3) != null
                                    ? RecipeCard(
                                        recipe: randomRecipe.elementAt(3))
                                    : Container(),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Center(child: Text('ไม่มีข้อมูล'));
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
              SizedBox(height: 20),
              // รายการค้นหาล่าสุด
              Text(
                'รายการค้นหาล่าสุด',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder(
                  future: recentSearch,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final recentSearch = snapshot.data!;

                        return Column(
                          children: recentSearch.map((search) {
                            final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                                .format(search.createdAt);
                            return _buildRecentSearch(
                                context, search.content, formattedDate);
                          }).toList(),
                        );
                      } else {
                        return Center(child: Text('ไม่มีข้อมูล'));
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  // รายการค้นหาล่าสุด
  Widget _buildRecentSearch(BuildContext context, String title, String date) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await SearchFoodApi.search(context, title, onGoBack: onSearchGoBack);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                      textStyle: theme.textTheme.bodyLarge?.copyWith()),
                ),
                Text(
                  date,
                  style: GoogleFonts.kanit(
                      textStyle: theme.textTheme.bodyMedium?.copyWith()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
