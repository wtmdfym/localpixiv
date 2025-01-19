import 'package:flutter/material.dart';

import '../../localization/localization_intl.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// About
class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/about';
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(
            title: MyLocalizations.of(context).settingsTitle('about')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [Text('About......')])));
  }
}
