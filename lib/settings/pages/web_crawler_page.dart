import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/tools.dart';
import '../../localization/localization.dart';
import '../../models.dart';
import '../../widgets/dialogs.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';
import '../tools.dart';

/// Pixiv webCrawler settings.
class WebCrawlerSettingsPage extends StatefulWidget {
  const WebCrawlerSettingsPage({super.key, required this.controller});
  static const routeName = '/webCrawler';
  final SettingsController controller;
  @override
  State<StatefulWidget> createState() => _WebCrawlerSettingsPageState();
}

class _WebCrawlerSettingsPageState extends State<WebCrawlerSettingsPage> {
  // localized text
  late String Function(String) _localizationMap;
  late String inputHintText;
  late String invalidFormatText;
  // cookie
  final TextEditingController _cookiecontroller = TextEditingController();
  late final WebCrawlerSettings webCrawlerSettings;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    webCrawlerSettings = widget.controller.webCrawlerSettings;
    _cookiecontroller.text = webCrawlerSettings.cookies.toString();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).webCrawlerPage;
    inputHintText = MyLocalizations.of(context).inputHintText;
    invalidFormatText = MyLocalizations.of(context).invalidFormat;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _cookiecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: _localizationMap('title'),
        onWillPop: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            widget.controller.updateWebCrawlerSettings(webCrawlerSettings);
          }
          return true;
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          canPop: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _cookiecontroller,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: _localizationMap('cookies'),
                    hintText: inputHintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return inputHintText;
                    } else if (value != webCrawlerSettings.cookies.toString()) {
                      Map<String, String> formatted = cookiesFormater(value);
                      if (formatted['PHPSESSID'] == null) {
                        return invalidFormatText;
                      } else {
                        _cookiecontroller.text = formatted.toString();
                        return null;
                      }
                    } else {
                      return null;
                    }
                  },
                  onSaved: (newValue) {
                    if (newValue != webCrawlerSettings.cookies.toString()) {
                      webCrawlerSettings.cookies =
                          Cookies.fromJson(cookiesFormater(newValue!));
                    }
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('enable_proxy'),
                  ),
                  value: webCrawlerSettings.enableProxy,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.enableProxy = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: webCrawlerSettings.httpProxies.substring(7),
                  maxLength: 30,
                  decoration: getInputDecoration(
                      _localizationMap('http_proxy'), inputHintText),
                  enabled: webCrawlerSettings.enableProxy,
                  validator: (value) {
                    if (webCrawlerSettings.enableProxy) {
                      if (value == null || value.isEmpty) {
                        return inputHintText;
                      } else {
                        if (value.replaceAll(RegExp(ipv4re), '').isNotEmpty &&
                            value.replaceAll(RegExp(ipv6re), '').isNotEmpty &&
                            value
                                .replaceAll(RegExp(localhostre), '')
                                .isNotEmpty) {
                          return invalidFormatText;
                        }
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (webCrawlerSettings.enableProxy) {
                      webCrawlerSettings.httpProxies = 'http://$newValue';
                    }
                  },
                ),
                TextFormField(
                  initialValue: webCrawlerSettings.httpsProxies.substring(8),
                  maxLength: 30,
                  decoration: getInputDecoration(
                      _localizationMap('https_proxy'), inputHintText),
                  enabled: webCrawlerSettings.enableProxy,
                  validator: (value) {
                    if (webCrawlerSettings.enableProxy) {
                      if (value == null || value.isEmpty) {
                        return inputHintText;
                      } else {
                        if (value.replaceAll(RegExp(ipv4re), '').isNotEmpty &&
                            value.replaceAll(RegExp(ipv6re), '').isNotEmpty &&
                            value
                                .replaceAll(RegExp(localhostre), '')
                                .isNotEmpty) {
                          return invalidFormatText;
                        }
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (webCrawlerSettings.enableProxy) {
                      webCrawlerSettings.httpsProxies = 'https://$newValue';
                    }
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('enable_resverse_proxy'),
                  ),
                  value: webCrawlerSettings.enableIPixiv,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.enableIPixiv = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: webCrawlerSettings.ipixivHostPath,
                  maxLength: 30,
                  decoration: getInputDecoration(
                      _localizationMap('resverse_proxy_example'),
                      inputHintText),
                  enabled: webCrawlerSettings.enableIPixiv,
                  onChanged: (value) {},
                  validator: (value) {
                    if (webCrawlerSettings.enableIPixiv) {
                      if (value == null || value.isEmpty) {
                        return inputHintText;
                      } else if (value
                          .replaceAll(RegExp(urlre), '')
                          .isNotEmpty) {
                        return invalidFormatText;
                      } else {
                        return null;
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (webCrawlerSettings.enableIPixiv) {
                      webCrawlerSettings.ipixivHostPath = newValue!;
                    }
                  },
                ),
                Text(
                  _localizationMap('download_style'),
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('illust'),
                  ),
                  value: webCrawlerSettings.downloadType.illust,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.downloadType.illust = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('manga'),
                  ),
                  value: webCrawlerSettings.downloadType.manga,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.downloadType.manga = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('novel'),
                  ),
                  value: webCrawlerSettings.downloadType.novel,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.downloadType.novel = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('ugoira'),
                  ),
                  value: webCrawlerSettings.downloadType.ugoira,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.downloadType.ugoira = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    _localizationMap('series'),
                  ),
                  value: webCrawlerSettings.downloadType.series,
                  onChanged: (value) {
                    setState(() {
                      webCrawlerSettings.downloadType.series = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: webCrawlerSettings.semaphore.toString(),
                  maxLength: 2,
                  decoration: getInputDecoration(
                      _localizationMap('concurrency'), inputHintText),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return inputHintText;
                    } else {
                      if (RegExp(r'\d{1,2}').matchAsPrefix(value) == null) {
                        return inputHintText;
                      } else {
                        if (int.parse(value) < 1) {
                          return _localizationMap('larger_than_one');
                        }
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) =>
                      webCrawlerSettings.semaphore = int.parse(newValue!),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 200,
                    children: [
                      Expanded(
                          child: SwitchListTile(
                        title: Text(
                          _localizationMap('client_pool'),
                        ),
                        value: webCrawlerSettings.enableClientPool,
                        onChanged: (value) {
                          setState(() {
                            webCrawlerSettings.enableClientPool = value;
                          });
                        },
                      )),
                      ElevatedButton(
                        onPressed: () {
                          if (webCrawlerSettings.enableClientPool) {
                            addClient(context).then((value) {
                              setState(() {
                                //print(value);
                                String clientInfo = value;
                                if (clientInfo.isNotEmpty) {
                                  webCrawlerSettings.clientPool.add(
                                      ClientPool.fromJson(
                                          jsonDecode(clientInfo)));
                                }
                              });
                            });
                          }
                        },
                        child: Text(
                          _localizationMap('add'),
                        ),
                      ),
                    ]),
                for (ClientPool clientPool in webCrawlerSettings.clientPool)
                  Offstage(
                      offstage: !webCrawlerSettings.enableClientPool,
                      child: ListTile(
                        title: Text(
                          'Email: ${clientPool.email}  ||  Cookies: ${clientPool.cookies.toString()}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              webCrawlerSettings.clientPool.remove(clientPool);
                            });
                          },
                        ),
                      )),
              ]),
        ),
      ),
    );
  }
}
