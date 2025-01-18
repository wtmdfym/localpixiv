import 'package:flutter/material.dart';

import '../../localization/localization_intl.dart';
import '../settings_controller.dart';
import '../back_appbar.dart';
import '../tools.dart';

/// Basic Settings
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/basic';
  @override
  State<StatefulWidget> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double _fontSize;

  @override
  void initState() {
    _fontSize = widget.controller.fontsize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String Function(String choice) getText =
        MyLocalizations.of(context).settingsContain;
    return Scaffold(
        appBar: BackAppBar(
            title: MyLocalizations.of(context).settingsTitle('basic')),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                canPop: true,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop = true) {
                    // 验证表单
                    if (_formKey.currentState!.validate()) {
                      // 保存表单数据
                      _formKey.currentState!.save();
                    }
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 20,
                    children: [
                      TextFormField(
                        initialValue: widget.controller.hostPath,
                        maxLength: 100,
                        decoration: getInputDecoration(
                            getText('hostPath'),
                            MyLocalizations.of(context)
                                .inputHintText(getText('hostPath'))),
                        validator: (value) {
                          RegExp pathre = RegExp(r'^[C-Z]\:[\\,\/].*');
                          if (value == null || value.isEmpty) {
                            return MyLocalizations.of(context)
                                .inputHintText(getText('hostPath'));
                          } else if (pathre.hasMatch(value)) {
                            return null;
                          } else {
                            return MyLocalizations.of(context)
                                .invalidFormat(getText('hostPath'));
                          }
                        },
                        onSaved: (newValue) =>
                            widget.controller.updateHostPath(newValue),
                      ),
                      DropdownButton<Locale>(
                        isExpanded: true,
                        // Read the selected locale from the controller
                        value: widget.controller.locale,
                        // Call the updateLocale method any time the user selects a theme.
                        onChanged: widget.controller.updateLocale,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('zh'),
                            child: Text('简体中文'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            MyLocalizations.of(context).setFontSize,
                            style: TextStyle(fontSize: _fontSize),
                          ),
                          Expanded(
                              child: Slider(
                            min: 8,
                            max: 24,
                            divisions: 8,
                            label: '$_fontSize',
                            value: _fontSize,
                            onChanged: (value) {
                              setState(() => _fontSize = value);
                            },
                            onChangeEnd: (value) {
                              setState(() {
                                widget.controller.updateFontsize(value);
                              });
                            },
                          )),
                        ],
                      ),
                    ]))));
  }
}
