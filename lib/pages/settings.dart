import 'package:flutter/material.dart';
import 'package:localpixiv/widgets/dialogs.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  bool _useProxy = true;
  bool _useClientPool = true;
  List<bool> dowmloadStyle = [true, true, true, true, false];
  final List<String> _items = [];

  // 删除Client
  void _removeClient(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        //spacing: 100,
        //children: [
        //Spacer(),
        child: SizedBox(
      width: 1920,
      child: Padding(
          padding: EdgeInsets.all(30),
          child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                spacing: 20,
                children: [
                  TextFormField(
                    initialValue: 'C://pixiv',
                    maxLength: 100,
                    style: TextStyle(
                      fontSize: 25,
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
                    onSaved: (newValue) => print(newValue),
                  ),
                  TextFormField(
                    //initialValue: 'C://pixiv',
                    //maxLength: 100,
                    minLines: 5,
                    maxLines: 5,
                    //expands: true,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 30),
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
                        // TODO验证
                      }
                      return null;
                    },
                    onSaved: (newValue) => print(newValue),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Enable Proxy',
                      style: TextStyle(fontSize: 25),
                    ),
                    value: _useProxy, //当前状态
                    onChanged: (value) {
                      // TODO 储存信息
                      //重新构建页面
                      setState(() {
                        _useProxy = value;
                      });
                    },
                  ),
                  TextFormField(
                    initialValue: 'http://localhost:12334',
                    maxLength: 30,
                    style: TextStyle(
                      fontSize: 25,
                    ),
                    decoration: getInputDecoration('Http Proxy'),
                    enabled: _useProxy,
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
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
                      return null;
                    },
                    onSaved: (newValue) => print(newValue),
                  ),
                  TextFormField(
                    initialValue: 'https://localhost:12334',
                    maxLength: 30,
                    style: TextStyle(
                      fontSize: 25,
                    ),
                    decoration: getInputDecoration('Https Proxy'),
                    enabled: _useProxy,
                    onChanged: (value) {
                      // 处理文本变化
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Https Proxy';
                      } else {
                        var regExp1 = RegExp(
                            r'https://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                        var localhostre = RegExp(r'https://localhost:\d{1,5}');
                        if (value.replaceAll(regExp1, '').isNotEmpty &&
                            value.replaceAll(localhostre, '').isNotEmpty) {
                          return 'Https Proxy 格式错误';
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) => print(newValue),
                  ),
                  Text(
                    'Download Style',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Illust',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    value: dowmloadStyle[0],
                    onChanged: (value) {
                      setState(() {
                        dowmloadStyle[0] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Manga',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    value: dowmloadStyle[1],
                    onChanged: (value) {
                      setState(() {
                        dowmloadStyle[1] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Novel',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    value: dowmloadStyle[2],
                    onChanged: (value) {
                      setState(() {
                        dowmloadStyle[2] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Ugoira',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    value: dowmloadStyle[3],
                    onChanged: (value) {
                      setState(() {
                        dowmloadStyle[3] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Series',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    value: dowmloadStyle[4],
                    onChanged: (value) {
                      setState(() {
                        dowmloadStyle[4] = value!;
                      });
                    },
                  ),
                  TextFormField(
                    initialValue: '2',
                    maxLength: 2,
                    style: TextStyle(
                      fontSize: 25,
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
                          return '请输入并发数';
                        }
                      }
                      return null;
                    },
                    onSaved: (newValue) => print(newValue),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Enable Client Pool',
                      style: TextStyle(fontSize: 25),
                    ),
                    value: _useClientPool, //当前状态
                    onChanged: (value) {
                      // TODO 储存信息
                      //重新构建页面
                      setState(() {
                        _useClientPool = value;
                      });
                    },
                  ),
                  Offstage(
                      offstage: !_useClientPool,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 200,
                            //使用 ListView.builder 来构建列表
                            child: ListView.builder(
                              itemExtent: 60,
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_items[index],
                                      style: TextStyle(
                                        fontSize: 25,
                                      )),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _removeClient(index),
                                  ),
                                );
                              },
                            ),
                          ),
                          // 添加按钮
                          ElevatedButton(
                            onPressed: () => addClient(context).then((value) {
                              setState(() {
                                //print(value);
                                String clientInfo = value;
                                if (clientInfo.isNotEmpty) {
                                  _items.add(clientInfo);
                                }
                              });
                            }),
                            child: Text('Add Client',
                                style: TextStyle(
                                  fontSize: 25,
                                )),
                          ),
                        ],
                      )),
                  Builder(builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        // 使用 Form.of(context) 来验证表单
                        if (Form.of(context).validate()) {
                          // 保存表单数据
                          Form.of(context).save();
                          // 处理表单提交
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 25,
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
    labelStyle: TextStyle(fontSize: 30),
    labelText: tip,
    hintText: '请输入$tip',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );
}