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
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              SwitchListTile(
                title: Text(
                    MyLocalizations.of(context).settingsContain('autoOpen')),
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
                    MyLocalizations.of(context).settingsContain('autoSearch'),
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
