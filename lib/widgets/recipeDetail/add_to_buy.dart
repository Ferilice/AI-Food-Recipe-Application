import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/database/local_database.dart';

import '../../database/database.dart';

/// A button that adds an ingredient to the To-Do List
class AddToBuyButton extends StatelessWidget {
  final String ingredientName;

  // final _db = LocalDatabase().database;

  const AddToBuyButton({super.key, required this.ingredientName});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add_circle, color: Colors.green),
      onPressed: () => _addToToDoList(context),
    );
  }

  /// ฟังก์ชันเพิ่มส่วนผสมลงใน To-Do List และแสดง Snackbar
  Future<void> _addToToDoList(BuildContext context) async {
    final _db = LocalDatabase().database;
    _db.into(_db.tobuys).insert(TobuysCompanion.insert(name: ingredientName));
    // แสดง Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เพิ่ม "$ingredientName" ลงใน To-Do List แล้ว!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
