import 'package:flutter/material.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

import '../../localization/localization.dart';
import '../settings_controller.dart';
import '../settings_dialogs.dart';
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
  // localized text
  late String Function(String) _localizationMap;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double _fontSize;
  late bool useMongoDB;
  late String languageCode;

  @override
  void initState() {
    _fontSize = widget.controller.fontsize;
    useMongoDB = widget.controller.useMongoDB;
    languageCode = widget.controller.locale.languageCode;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).basicPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: _localizationMap('title')),
      body: Padding(
          padding: const EdgeInsets.all(8),
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
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              TextFormField(
                initialValue: widget.controller.hostPath,
                maxLength: 100,
                decoration: getInputDecoration(_localizationMap('host_path'),
                    MyLocalizations.of(context).inputHintText),
                validator: (value) {
                  RegExp pathre = RegExp(r'^[C-Z]\:[\\,\/].*');
                  if (value == null || value.isEmpty) {
                    return MyLocalizations.of(context).inputHintText;
                  } else if (pathre.hasMatch(value)) {
                    return null;
                  } else {
                    return MyLocalizations.of(context).invalidFormat;
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
                onChanged: (value) =>
                    {widget.controller.updateLocale(value), setState(() {})},
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
                    _localizationMap('font_size'),
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
              Text(
                'TESTING',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SwitchListTile(
                title: Text(_localizationMap('use_mongo_db')),
                value: useMongoDB,
                onChanged: (value) {
                  setState(() {
                    useMongoDB = value;
                    widget.controller.updateMongoDb(useMongoDB);
                  });
                },
              ),
              TextFormField(
                enabled: useMongoDB,
                initialValue: widget.controller.serverHost,
                maxLength: 100,
                decoration: getInputDecoration(_localizationMap('server_host'),
                    MyLocalizations.of(context).inputHintText),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return MyLocalizations.of(context).inputHintText;
                  } else {
                    var mongoipv4re = RegExp(
                        r'mongodb://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                    var mongolocalhostre =
                        RegExp(r'mongodb://localhost:\d{1,5}');
                    // TODO ipv6 (?<=]:).*\w+
                    if (value.replaceAll(mongoipv4re, '').isNotEmpty &&
                        value.replaceAll(mongolocalhostre, '').isNotEmpty) {
                      return MyLocalizations.of(context).invalidFormat;
                    }
                  }
                  return null;
                },
                onSaved: (newValue) {
                  widget.controller
                      .updateMongoDb(useMongoDB, serverHost: newValue);
                },
              ),
              Expanded(
                child: SettingsList(sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.navigation(
                        title: Text('Host Path'),
                        description: Text(widget.controller.hostPath),
                        onPressed: (context) async {
                          final file = DirectoryPicker()
                            ..title = 'Select a directory';

                          final result = file.getDirectory();
                          if (result != null) {
                            await widget.controller.updateHostPath(result.path);
                            setState(() {});
                          }
                        },
                      ),
                      SettingsTile(
                        title: Text(
                          'FontSize',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        trailing: Slider(
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
                        ),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Text('Language'),
                    tiles: [
                      SettingsTile<String>.radioTile(
                        title: Text('English'),
                        radioValue: 'en',
                        groupValue: languageCode,
                        onChanged: (value) => setState(() {
                          languageCode = value!;
                          widget.controller.updateLocale(Locale(value));
                        }),
                      ),
                      SettingsTile<String>.radioTile(
                        title: Text('简体中文'),
                        radioValue: 'zh',
                        groupValue: languageCode,
                        onChanged: (value) => setState(() {
                          languageCode = value!;
                          widget.controller.updateLocale(Locale(value));
                        }),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Text('MongoDB Settings'),
                    tiles: [
                      SettingsTile.switchTile(
                        title: Text(_localizationMap('use_mongo_db')),
                        initialValue: useMongoDB,
                        onToggle: (value) {
                          setState(() {
                            useMongoDB = value ?? !useMongoDB;
                            widget.controller.updateMongoDb(useMongoDB);
                          });
                        },
                      ),
                      SettingsTile.navigation(
                        title: Text('MongoDB Server Host'),
                        description: Text(
                            'Current Url: ${widget.controller.serverHost}'),
                        enabled: useMongoDB,
                        onPressed: (context) async {
                          String? newHostPath = await inputDialog(
                            context,
                            'MongoDB Server Host',
                            initialValue: widget.controller.serverHost,
                            decoration: getInputDecoration(
                                _localizationMap('server_host'),
                                MyLocalizations.of(context).inputHintText),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return MyLocalizations.of(context)
                                    .inputHintText;
                              } else {
                                var mongoipv4re = RegExp(
                                    r'mongodb://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                                var mongolocalhostre =
                                    RegExp(r'mongodb://localhost:\d{1,5}');
                                if (value
                                        .replaceAll(mongoipv4re, '')
                                        .isNotEmpty &&
                                    value
                                        .replaceAll(mongolocalhostre, '')
                                        .isNotEmpty) {
                                  return MyLocalizations.of(context)
                                      .invalidFormat;
                                }
                              }
                              return null;
                            },
                          );
                          widget.controller.updateMongoDb(useMongoDB,
                              serverHost: newHostPath);
                        },
                      ),
                    ],
                  )
                ]),
              )
            ]),
          )),
    );
  }
}
