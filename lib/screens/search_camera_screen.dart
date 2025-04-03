// 640510646 Jedsadaporn Nedpab
// 640510675 Poomiputh Boonma

import 'package:flutter/material.dart';

/// A placeholder widget to place on BottomNavigation widget for the search camera
class SearchCameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        'ค้นหา',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface, // ใช้สีของ primary color
        ),
      )),
      // body: Center(
      //   child: Text('นี่คือหน้าค้นหา', style: TextStyle(fontSize: 24)),
      // ),
    );
  }
}
