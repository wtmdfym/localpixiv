import 'package:flutter/material.dart';

import '../../localization/localization.dart';
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
  // localized text
  late String Function(String) _localizationMap;
  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).otherPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(title: _localizationMap('title')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisSize: MainAxisSize.min, spacing: 20, children: [])));
  }
}
