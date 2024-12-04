import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/common/tools.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.configs});
  final Configs configs;
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  // 删除Client
  void _removeClient(int index) {
    setState(() {
      widget.configs.clientPool!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Configs newConfigs = Configs();
    return SingleChildScrollView(
        //spacing: 100,
        //children: [
        //Spacer(),
        child: SizedBox(
      width: 1920,
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                spacing: 20,
                children: [
                  TextFormField(
                    initialValue: widget.configs.savePath,
                    maxLength: 100,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: getInputDecoration('Save Path'),
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Save Path';
                      } else {}
                      return null;
                    },
                    onSaved: (newValue) => widget.configs.savePath = newValue,
                  ),
                  TextFormField(
                    initialValue: widget.configs.cookies.toString(),
                    //maxLength: 100,
                    minLines: 5,
                    maxLines: 5,
                    //expands: true,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 24),
                      labelText: 'Cookies',
                      hintText: '请输入你要爬取的账号的Cookies',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Cookies';
                      } else {
                        if (value != widget.configs.cookies.toString()) {
                          if (cookiesFormater(value)['PHPSESSID'] == null) {
                            return 'Cookies值错误';
                          }
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      if (newValue != widget.configs.cookies.toString()) {
                        widget.configs.cookies =
                            Cookies.fromJson(cookiesFormater(newValue!));
                      }
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Enable Proxy',
                      style: TextStyle(fontSize: 20),
                    ),
                    value: widget.configs.enableProxy, //当前状态
                    onChanged: (value) {
                      //重新构建页面
                      setState(() {
                        widget.configs.enableProxy = value;
                      });
                    },
                  ),
                  TextFormField(
                    initialValue: widget.configs.httpProxies,
                    maxLength: 30,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: getInputDecoration('Http Proxy'),
                    enabled: widget.configs.enableProxy,
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (widget.configs.enableProxy) {
                        if (value == null || value.isEmpty) {
                          return '请输入Http Proxy';
                        } else {
                          var ipv4re = RegExp(
                              r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                          var localhostre = RegExp(r'http://localhost:\d{1,5}');
                          // TODO ipv6 (?<=]:).*\w+
                          if (value.replaceAll(ipv4re, '').isNotEmpty &&
                              value.replaceAll(localhostre, '').isNotEmpty) {
                            return 'Http Proxy 格式错误';
                          }
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      if (widget.configs.enableProxy) {
                        widget.configs.httpProxies = newValue;
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: widget.configs.httpsProxies,
                    maxLength: 30,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: getInputDecoration('Https Proxy'),
                    enabled: widget.configs.enableProxy,
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (widget.configs.enableProxy) {
                        if (value == null || value.isEmpty) {
                          return '请输入Https Proxy';
                        } else {
                          var regExp1 = RegExp(
                              r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                          var localhostre = RegExp(r'http://localhost:\d{1,5}');
                          if (value.replaceAll(regExp1, '').isNotEmpty &&
                              value.replaceAll(localhostre, '').isNotEmpty) {
                            return 'Https Proxy 格式错误';
                          }
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      if (widget.configs.enableProxy) {
                        widget.configs.httpsProxies = newValue;
                      }
                    },
                  ),
                  Text(
                    'Download Style',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Illust',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    value: widget.configs.downloadType!.illust, //[0],
                    onChanged: (value) {
                      setState(() {
                        widget.configs.downloadType!.illust = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Manga',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    value: widget.configs.downloadType!.manga, //[1],
                    onChanged: (value) {
                      setState(() {
                        widget.configs.downloadType!.manga = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Novel',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    value: widget.configs.downloadType!.novel,
                    onChanged: (value) {
                      setState(() {
                        widget.configs.downloadType!.novel = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Ugoira',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    value: widget.configs.downloadType!.ugoira,
                    onChanged: (value) {
                      setState(() {
                        widget.configs.downloadType!.ugoira = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Series',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    value: widget.configs.downloadType!.series,
                    onChanged: (value) {
                      setState(() {
                        widget.configs.downloadType!.series = value!;
                      });
                    },
                  ),
                  TextFormField(
                    initialValue: '2',
                    maxLength: 2,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: getInputDecoration('Concurrency'),
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入并发数';
                      } else {
                        if (RegExp(r'\d{1,2}').matchAsPrefix(value) == null) {
                          return '请输入数字';
                        } else {
                          if (int.parse(value) < 1) {
                            return '并发数不能小于1';
                          }
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) =>
                        widget.configs.semaphore = int.tryParse(newValue!),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 400,
                      children: [
                        SizedBox(
                            width: 400,
                            child: SwitchListTile(
                              title: Text(
                                'Enable Client Pool',
                                style: TextStyle(fontSize: 20),
                              ),
                              value: widget.configs.enableClientPool, //当前状态
                              onChanged: (value) {
                                //重新构建页面
                                setState(() {
                                  widget.configs.enableClientPool = value;
                                });
                              },
                            )),
                        // 添加按钮
                        ElevatedButton(
                          onPressed: () => widget.configs.enableClientPool
                              ? addClient(context).then((value) {
                                  setState(() {
                                    //print(value);
                                    String clientInfo = value;
                                    if (clientInfo.isNotEmpty) {
                                      widget.configs.clientPool!.add(
                                          ClientPool.fromJson(
                                              jsonDecode(clientInfo)));
                                    }
                                  });
                                })
                              : {},
                          child: Text('Add Client',
                              style: TextStyle(
                                fontSize: 20,
                              )),
                        ),
                      ]),
                  Offstage(
                      offstage: !widget.configs.enableClientPool,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 200,
                            //使用 ListView.builder 来构建列表
                            child: ListView.builder(
                              itemExtent: 60,
                              itemCount: widget.configs.clientPool!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      'Email: ${widget.configs.clientPool![index].email}  ||  Cookies: ${widget.configs.clientPool![index].cookies.toString()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _removeClient(index);
                                      widget.configs.clientPool!
                                          .removeAt(index);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )),
                  /*Row(
                      spacing: 50,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [*/
                  Divider(),
                  //UI 相关设置
                  Text(
                    'UI Settings',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Auto search when click tag',
                      style: TextStyle(fontSize: 20),
                    ),
                    value: widget.configs.uiConfigs.autoSearch, //当前状态
                    onChanged: (value) {
                      //重新构建页面
                      setState(() {
                        widget.configs.uiConfigs.autoSearch = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MaxImageCacheRate(unused)',
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                          child: Slider(
                        max: 4,
                        divisions: 4,
                        label: widget.configs.uiConfigs.maxImageCacheRate == 0
                            ? 'Not limited'
                            : '${widget.configs.uiConfigs.maxImageCacheRate}',
                        value: widget.configs.uiConfigs.maxImageCacheRate,
                        onChanged: (value) {
                          //重新构建页面
                          setState(() {
                            widget.configs.uiConfigs.maxImageCacheRate = value;
                          });
                        },
                      )),
                    ],
                  ),

                  // 保存button
                  Builder(builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        // 使用 Form.of(context) 来验证表单
                        if (Form.of(context).validate()) {
                          setState(() {
                            // 保存表单数据
                            Form.of(context).save();
                            // 写入配置文件
                            //File jsonFile = File('jsons/test.json');
                            configManger(
                                    'jsons/config.json', 'w', widget.configs)
                                ? resultDialog(context, 'Save configs', true)
                                : resultDialog(context, 'Save configs', false);
                          });
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  }),
                ],
              ))),
    ));
  }
}

InputDecoration getInputDecoration(String tip) {
  return InputDecoration(
    labelStyle: TextStyle(fontSize: 24),
    labelText: tip,
    hintText: '请输入$tip',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );
}
