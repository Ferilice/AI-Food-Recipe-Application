// 640510646 Jedsadaporn Nedpab
// 640510675 Poomiputh Boonma

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'database_browse.dart';

/// A widget to display and manage application settings.
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'ตั้งค่า',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface, // ใช้สีของ primary color
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // _buildSettingItem(context, 'ภาษา'),
          // _buildSettingItem(context, 'เกี่ยวกับแอปพลิเคชัน'),
          _buildToggleSetting(context, 'ธีม', isThemeSwitch: true),
          _buildButtonSetting(context, 'ฐานข้อมูล', onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DatabaseBrowse()));
          }),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(BuildContext context, String title,
      {bool isThemeSwitch = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return ListTile(
      title: Text(title),
      trailing: isThemeSwitch
          ? Switch(
              value: themeProvider.isDarkMode,
              activeColor:
                  themeProvider.isDarkMode ? Colors.white : Color(0xFFA31621),
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            )
          : Icon(Icons.chevron_right),
    );
  }

  Widget _buildButtonSetting(BuildContext context, String title,
      {Function()? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
