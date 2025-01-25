import 'package:flutter/material.dart';

import '../../localization/localization.dart';
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
  // localized text
  late String Function(String) _localizationMap;
  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).aboutPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(title: _localizationMap('title')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [Text(_localizationMap('about'))])));
  }
}
