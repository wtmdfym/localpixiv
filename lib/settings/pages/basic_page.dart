import 'package:flutter/material.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:localpixiv/models.dart';

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
                    min: 10,
                    max: 20,
                    divisions: 5,
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
                initialValue: widget.controller.serverHost.substring(10),
                maxLength: 100,
                decoration: getInputDecoration(_localizationMap('server_host'),
                    MyLocalizations.of(context).inputHintText),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return MyLocalizations.of(context).inputHintText;
                  } else {
                    if (value.replaceAll(RegExp(ipv4re), '').isNotEmpty &&
                        value.replaceAll(RegExp(ipv6re), '').isNotEmpty &&
                        value.replaceAll(RegExp(localhostre), '').isNotEmpty) {
                      return MyLocalizations.of(context).invalidFormat;
                    }
                  }
                  return null;
                },
                onSaved: (newValue) {
                  widget.controller.updateMongoDb(useMongoDB,
                      serverHost: 'mongodb://$newValue');
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
                          min: 10,
                          max: 20,
                          divisions: 5,
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
                            'Current Url: ${widget.controller.serverHost.substring(10)}'),
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
                                if (value
                                        .replaceAll(RegExp(ipv4re), '')
                                        .isNotEmpty &&
                                    value
                                        .replaceAll(RegExp(ipv6re), '')
                                        .isNotEmpty &&
                                    value
                                        .replaceAll(RegExp(localhostre), '')
                                        .isNotEmpty) {
                                  return MyLocalizations.of(context)
                                      .invalidFormat;
                                }
                              }
                              return null;
                            },
                          );
                          widget.controller.updateMongoDb(useMongoDB,
                              serverHost: 'mongodb://$newHostPath');
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
