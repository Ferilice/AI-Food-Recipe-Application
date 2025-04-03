// 640510646 Jedsadaporn Nedpab
// 640510675 Poomiputh Boonma

import 'package:flutter/material.dart';

import '../database/database.dart';
import '../database/local_database.dart';
import '../widgets/bookmark/bookmark_checkbox.dart';
import '../widgets/recipeDetail/add_to_buy.dart';

/// A widget that displays the details of a given recipe.
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _db = LocalDatabase().database;
  late Future<List<(Bookmark, $$BookmarksTableReferences)>> bookmarks;

  Future<List<(Bookmark, $$BookmarksTableReferences)>> getBookmarks() async {
    final result = await _db.managers.bookmarks
        .withReferences((prefetch) => prefetch(bookmark: true))
        .get();
    return result;
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกบันทึกเมนู'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                  future: bookmarks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final bookmarks = snapshot.data!;
                        return Column(
                          children: bookmarks
                              .map((bookmarkAndRef) => ListTile(
                                    title: Text(bookmarkAndRef.$1.name),
                                    trailing: BookmarkCheckbox(
                                      recipe: widget.recipe,
                                      bookmarkAndRef: bookmarkAndRef,
                                      onChanged: (value) {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ))
                              .toList(),
                        );
                      } else {
                        return Text('ไม่มีบันทึกเมนู');
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
              Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด Dialog
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.secondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: isDark
                ? Colors.black.withAlpha(200)
                : Colors.blue.withAlpha(200),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.recipe.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) =>
                      Image.asset('assets/images/food_placeholder.png')),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.bookmark_border,
                  color: Colors.white, // ให้ไอคอนสีขาวในโหมดมืดหรือสว่าง
                ),
                onPressed: () {
                  bookmarks = getBookmarks();
                  _showSaveDialog(context);
                }, // เรียก Dialog
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      widget.recipe.isLlmGenerated
                          ? Text('สร้างโดย Food Guru',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))
                          : Text('จากฐานข้อมูล',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('${widget.recipe.totalCalories} แคล',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Divider(),
                      Text('ส่วนผสม',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ...widget.recipe.ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ingredient.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black)),
                                Row(
                                  children: [
                                    Text(
                                        '${ingredient.quantity} ${ingredient.unit}',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.red)),
                                    SizedBox(width: 10),
                                    AddToBuyButton(
                                        ingredientName: ingredient.name),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Divider(),
                      Text('วิธีทำ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ...widget.recipe.instructions
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${entry.key + 1}. ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor)),
                                    Expanded(
                                      child: Text(entry.value,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
