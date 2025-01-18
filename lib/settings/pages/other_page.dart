import 'package:flutter/material.dart';

import '../../localization/localization_intl.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// Other
class OtherSettingsPage extends StatefulWidget {
  const OtherSettingsPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/other';
  @override
  State<StatefulWidget> createState() => _OtherSettingsPageState();
}

class _OtherSettingsPageState extends State<OtherSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(
            title: MyLocalizations.of(context).settingsTitle('other')),
        body:
           Padding(
            padding: EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [])));
  }
}
