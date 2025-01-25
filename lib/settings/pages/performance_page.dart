import 'package:flutter/material.dart';

import '../../localization/localization.dart';
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
  // localized text
  late String Function(String) _localizationMap;
  late double _cacheRate;

  @override
  void initState() {
    _cacheRate = widget.controller.imageCacheRate;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).performancePage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BackAppBar(title: _localizationMap('title')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_localizationMap('image_cache_rate')),
                  Expanded(
                      child: Slider(
                    max: 4,
                    divisions: 8,
                    label: _cacheRate == 0
                        ? _localizationMap('not_limited')
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
