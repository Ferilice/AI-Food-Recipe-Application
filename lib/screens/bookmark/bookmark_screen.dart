import 'package:drift/drift.dart' as drift;
import 'package:flutter_application_group_project/database/local_database.dart';
import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../widgets/personalList/add_recipe_list_dialog.dart';
import '../../widgets/personalList/edit_recipe_list_dialog.dart';
import 'bookmark_detail_screen.dart';

/// A widget to do CRUD operations on bookmarks.
class BookMarkScreen extends StatefulWidget {
  const BookMarkScreen({super.key});

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookMarkScreen> {
  final _db = LocalDatabase().database;

  void _addBookmark() {
    showDialog(
      context: context,
      builder: (context) => AddPlaylistDialog(
        onAdd: (name) {
          setState(() {
            _db.into(_db.bookmarks).insert(BookmarksCompanion(
                  name: drift.Value(name),
                  description: drift.Value(''),
                ));
          });
        },
      ),
    );
  }

  void _editBookmark(Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => EditPlaylistDialog(
        initialName: bookmark.name,
        onEdit: (name) {
          setState(() {
            _db.update(_db.bookmarks)
              ..where((tbl) => tbl.id.equals(bookmark.id))
              ..write(BookmarksCompanion(name: drift.Value(name)));
          });
        },
      ),
    );
  }

  void _deleteBookmark(Bookmark bookmark) {
    setState(() {
      (_db.delete(_db.bookmarks)..where((tbl) => tbl.id.equals(bookmark.id)))
          .go();
    });
  }

  Future<List<Bookmark>> getBookmarks() async {
    final result = await _db.select(_db.bookmarks).get();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 2,
        title: Text(
          "บันทึกเมนู",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
              future: getBookmarks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final bookmarks = snapshot.data!;
                    return bookmarks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_border,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('ไม่มีรายการบันทึก',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 8),
                                Text(
                                  'คุณยังไม่ได้บันทึกรายการอาหาร',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: bookmarks.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookmarkDetailScreen(
                                          bookmark: bookmarks.elementAt(index)),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          bookmarks.elementAt(index).name,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: PopupMenuButton<String>(
                                          color: Colors.white,
                                          onSelected: (value) {
                                            if (value == "edit") {
                                              _editBookmark(
                                                  bookmarks.elementAt(index));
                                            }
                                            if (value == "delete") {
                                              _deleteBookmark(
                                                  bookmarks.elementAt(index));
                                            }
                                            ;
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: "edit",
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 20),
                                                  SizedBox(width: 8),
                                                  Text("แก้ไขชื่อ"),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: "delete",
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, size: 20),
                                                  SizedBox(width: 8),
                                                  Text("ลบ"),
                                                ],
                                              ),
                                            ),
                                          ],
                                          icon: Icon(Icons.more_vert,
                                              color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  } else {
                    return Center(child: Text('ไม่มีข้อมูล'));
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBookmark(),
        shape: CircleBorder(),
        elevation: 10,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 36),
      ),
    );
  }
}
