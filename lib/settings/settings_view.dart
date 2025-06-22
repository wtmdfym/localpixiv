import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';

import '../localization/localization.dart';
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
    // localized text
    final String Function(String) localizationMap =
        MyLocalizations.of(context).settingsPage;
    return Padding(
      padding: const EdgeInsets.all(8),
      //'basic' 'theme' 'search' 'performance' 'webCrawler' 'other' 'about'
      child: Column(
        children: [
          SettingsSection(tiles: [
            SettingsTile.navigation(
              leading: Icon(Icons.border_all_outlined),
              title: Text(
                localizationMap('basic'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BasicSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.color_lens_outlined),
              title: Text(
                localizationMap('theme'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ThemeSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.image_search_outlined),
              title: Text(
                localizationMap('search'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SearchSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.av_timer_outlined),
              title: Text(
                localizationMap('performance'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PerformanceSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.bug_report_outlined),
              title: Text(
                localizationMap('webCrawler'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WebCrawlerSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.start_outlined),
              title: Text(
                localizationMap('other'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OtherSettingsPage(controller: controller))),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.info_outline),
              title: Text(
                localizationMap('about'),
              ),
              onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutPage(controller: controller))),
            ),
          ])
          /*ListTile(
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
            leading: Icon(Icons.info_outline),
            title: Text(MyLocalizations.of(context).settingsTitle('about'),
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.navigate_next),
          ),*/
        ],
      ),
    );
  }
}
