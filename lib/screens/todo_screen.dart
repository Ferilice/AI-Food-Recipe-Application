// 640510646 Jedsadaporn Nedpab
// 640510675 Poomiputh Boonma

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_application_group_project/database/database.dart';
import 'package:flutter_application_group_project/database/local_database.dart';
import '../widgets/to-buy/add_task_dialog.dart';
import '../widgets/to-buy/edit_task_dialog.dart';
import '../widgets/to-buy/confirm_delete_dialog.dart';

/// A widget to do CRUD operations on to-buy tasks.
class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _db = LocalDatabase().database;

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          onTaskAdded: (newTask) {
            setState(() {
              _db
                  .into(_db.tobuys)
                  .insert(TobuysCompanion.insert(name: newTask));
            });
          },
        );
      },
    );
  }

  void _toggleTask(Tobuy tobuy) {
    setState(() {
      _db.update(_db.tobuys)
        ..where((e) => e.id.equals(tobuy.id))
        ..write(TobuysCompanion(isCompleted: drift.Value(!tobuy.isCompleted)));
    });
  }

  void _editTask(Tobuy tobuy) {
    showDialog(
      context: context,
      builder: (context) {
        return EditTaskDialog(
          currentTask: tobuy.name,
          onTaskUpdated: (newName) {
            setState(() {
              _db.update(_db.tobuys)
                ..where((e) => e.id.equals(tobuy.id))
                ..write(TobuysCompanion(name: drift.Value(newName)));
            });
          },
        );
      },
    );
  }

  void _confirmDeleteTask(Tobuy tobuy) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDeleteDialog(
          taskName: tobuy.name,
          onConfirm: () {
            setState(() {
              (_db.delete(_db.tobuys)..where((e) => e.id.equals(tobuy.id)))
                  .go();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // var isListEmpty = false;

    Future<List<Tobuy>> _loadTobuys() async {
      return await _db.select(_db.tobuys).get();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'แผนของฉัน',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface, // ใช้สีของ primary color
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder(
          future: _loadTobuys(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final tobuys = snapshot.data as List<Tobuy>;
                return tobuys.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ยังไม่มีแผนการ',
                                style: theme.textTheme.bodyLarge),
                            SizedBox(height: 8),
                            Text('คุณยังไม่เพิ่มแผนใดๆ ที่ต้องทำ',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            if (tobuys
                                .where((e) => !e.isCompleted)
                                .isNotEmpty) ...[
                              Text(
                                  'ต้องทำ (${tobuys.where((e) => !e.isCompleted).length})',
                                  style: theme.textTheme.titleMedium),
                              SizedBox(height: 8),
                              ...tobuys.where((e) => !e.isCompleted).map((e) {
                                return Card(
                                  color: theme.cardColor,
                                  child: ListTile(
                                    title: Text(e.name,
                                        style: theme.textTheme.bodyLarge),
                                    leading: IconButton(
                                      icon: Icon(Icons.radio_button_unchecked,
                                          color: theme.iconTheme.color),
                                      onPressed: () => _toggleTask(e),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () => _editTask(e),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDeleteTask(e),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            SizedBox(height: 16),
                            if (tobuys
                                .where((e) => e.isCompleted)
                                .isNotEmpty) ...[
                              Text(
                                  'สำเร็จ (${tobuys.where((e) => e.isCompleted).length})',
                                  style: theme.textTheme.titleMedium),
                              SizedBox(height: 8),
                              ...tobuys.where((e) => e.isCompleted).map((e) {
                                return Card(
                                  color: theme.cardColor,
                                  child: ListTile(
                                    title: Text(
                                      e.name,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.red,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                    leading: IconButton(
                                      icon: Icon(Icons.check_circle,
                                          color: Colors.green),
                                      onPressed: () => _toggleTask(e),
                                    ),
                                    trailing: IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDeleteTask(e),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('เกิดข้อผิดพลาด', style: theme.textTheme.bodyLarge),
                      SizedBox(height: 8),
                      Text('ไม่สามารถโหลดข้อมูลได้',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey)),
                    ],
                  ),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        shape: CircleBorder(),
        elevation: 10,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white, size: 36),
      ),
    );
  }
}
