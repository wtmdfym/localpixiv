import 'package:flutter/material.dart';

import '../localization/localization_intl.dart';
import 'pages/basic_page.dart';
import 'pages/theme_page.dart';
import 'pages/search_page.dart';
import 'pages/performance_page.dart';
import 'pages/web_crawler_page.dart';
import 'pages/other_page.dart';
import 'pages/about_page.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      // Glue the SettingsController to the theme selection DropdownButton.
      //
      // When a user selects a theme from the dropdown list, the
      // SettingsController is updated, which rebuilds the MaterialApp.
      child: Column(
        children: [
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BasicSettingsPage(controller: controller))),
              title: Text(MyLocalizations.of(context).settingsTitle('basic'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ThemeSettingsPage(controller: controller),
                  )),
              title: Text(MyLocalizations.of(context).settingsTitle('theme'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchSettingsPage(controller: controller),
                  )),
              title: Text(MyLocalizations.of(context).settingsTitle('search'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PerformanceSettingsPage(controller: controller),
                  )),
              title: Text(
                  MyLocalizations.of(context).settingsTitle('performance'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WebCrawlerSettingsPage(controller: controller),
                  )),
              title: Text(
                  MyLocalizations.of(context).settingsTitle('webCrawler'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OtherSettingsPage(controller: controller),
                  )),
              title: Text(MyLocalizations.of(context).settingsTitle('other'),
                  style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(controller: controller),
                  )),
              title: Text(MyLocalizations.of(context).settingsTitle('about'),
                  style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}
