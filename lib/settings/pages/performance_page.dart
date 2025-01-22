import 'package:flutter/material.dart';

import '../../localization/localization_intl.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// Performance
class PerformanceSettingsPage extends StatefulWidget {
  const PerformanceSettingsPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/performance';
  @override
  State<StatefulWidget> createState() => _PerformanceSettingsPageState();
}

class _PerformanceSettingsPageState extends State<PerformanceSettingsPage> {
  late double _cacheRate;
  @override
  void initState() {
    _cacheRate = widget.controller.imageCacheRate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(
            title: MyLocalizations.of(context).settingsTitle('performance')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(MyLocalizations.of(context).settingsContain('icr')),
                  Expanded(
                      child: Slider(
                    max: 4,
                    divisions: 8,
                    label: _cacheRate == 0
                        ? MyLocalizations.of(context).settingsContain('nl')
                        : '$_cacheRate',
                    value: _cacheRate,
                    onChanged: (value) {
                      setState(() => _cacheRate = value);
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        widget.controller.updateImageCacheRate(value);
                      });
                    },
                  )),
                ],
              ),
            ])));
  }
}
