import 'package:flutter/material.dart';

import '../../localization/localization_intl.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// Search
class SearchSettingsPage extends StatefulWidget {
  const SearchSettingsPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/search';
  @override
  State<StatefulWidget> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends State<SearchSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(
            title: MyLocalizations.of(context).settingsTitle('search')),
        body: Padding(
            padding: EdgeInsets.all(20),
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              SwitchListTile(
                title: Text(
                  'Auto open user detial page when click user infos',
                ),
                value: widget.controller.autoOpen,
                onChanged: (value) {
                  // 通知UI更新
                  setState(() {
                    widget.controller.updateAutoOpen(value);
                  });
                },
              ),
              SwitchListTile(
                  title: Text(
                    'Auto search when click tag',
                  ),
                  value: widget.controller.autoSearch,
                  onChanged: (value) {
                    setState(() {
                      widget.controller.updateAutoSearch(value);
                    });
                  }),
            ])));
  }
}
