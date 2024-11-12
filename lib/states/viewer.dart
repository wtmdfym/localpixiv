import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localpixiv/widgets/workcontainer.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

const String defaultdata = '''
{
  "type": "illust",
  "id": 114514,
  "title": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌",
  "description": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌+و(◠ڼ◠)٩ =꒰ঌ(🎀ᗜ v ᗜ 🌸)໒꒱✅",
  "tags": {
    "水着": "泳装",
    "女の子": "女孩子",
    "オリジナル": "原创",
    "太もも": "大腿",
    "海": "sea",
    "浮き輪": "游泳圈",
    "イラスト": "插画"
  },
  "userId": "114514",
  "username": "Man",
  "uploadDate": "2042",
  "likeData": true,
  "isOriginal": true,
  "imageCount": 1,
  "relative_path": [
    "what can I say"
  ]
}
''';

class Viewer extends StatefulWidget {
  const Viewer({
    super.key,
    required this.pixivDb,
    required this.backupcollection,
    required this.configs,
    //required this.channel,
  });
  final mongo.Db pixivDb;
  final mongo.DbCollection backupcollection;
  final Configs configs;
  //final WebSocketChannel channel;

  @override
  State<StatefulWidget> createState() {
    return _ViewerState();
  }
}

class _ViewerState extends State<Viewer> {
  ///************************///
  ///*********初始化*********///
  ///************************///
  int page = 1;
  int maxpage = 1;
  final int pagesize = 8;
  bool cancelevent = false;
  final List<dynamic> searchedInfos = [];
  final List<WorkInfoNotifier> workInfoNotifers = [
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
  ];
  //WorkInfoNotifier(WorkInfo(id: 1,imagePath: ['images/default\.png'],imageInfo: {'imagecount':1}))
  final WorkInfoNotifier showingInfo =
      WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata)));
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');
  /*ValueNotifier<List<bool>> searchType =
      ValueNotifier([true, false, false]); //id  uid tag*/
  final List<dynamic> workInfos = [];
  int reslength = 0;
  final int buffer = 200;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  bool onsearching = false;

  /// ************************* ///
  /// *********搜索控制********* ///
  /// ************************* ///
  void searchAnalyzer(
      [Map<String, dynamic>? advancedtext,
      mongo.SelectorBuilder? finishedselector]) {
    if (onsearching) {
      resultDialog(context, 'Search', false,
          'Searching operation not complete!\nPlease wait.');
      return;
    }
    _isLoading.value = true;
    mongo.SelectorBuilder selector = mongo.SelectorBuilder().exists('id');
    if (advancedtext != null) {
      if (advancedtext.isNotEmpty) {
        bool searchtag = true;
        bool partly = true;
        if (advancedtext['searchRange'] == 'tag(partly)') {
        } else if (advancedtext['searchRange'] == 'tag(absolutely)') {
          partly = false;
        } else {
          searchtag = false;
        }
        //tag search
        if (searchtag) {
          //匹配tag
          if (!partly) {
            for (String keyword in advancedtext['AND']) {
              if (keyword.isNotEmpty) {
                selector.and(mongo.where.exists('tags.$keyword'));
              }
            }
            for (String keyword in advancedtext['NOT']) {
              if (keyword.isNotEmpty) {
                selector.and(mongo.where.notExists('tags.$keyword'));
              }
            }
            for (String keyword in advancedtext['OR']) {
              if (keyword.isNotEmpty) {
                selector.or(mongo.where.exists('tags.$keyword'));
              }
            }
          }
          //匹配tag和翻译
          else {
            for (String keyword in advancedtext['AND']) {
              if (keyword.isNotEmpty) {
                selector.match('tags', keyword, multiLine: true);
              }
            }
            for (String keyword in advancedtext['NOT']) {
              if (keyword.isNotEmpty) {
                selector.raw({
                  'tags': {'\$not': RegExp(keyword, multiLine: true)}
                });
              }
            }

            for (String keyword in advancedtext['OR']) {
              if (keyword.isNotEmpty) {
                selector
                    .or(mongo.where.match('tags', keyword, multiLine: true));
              }
            }
          }
        }
        //title and description search
        else {
          /*
          TODO 聚合查询
          var title = mongo.SelectorBuilder();
          var description = mongo.SelectorBuilder();
          for (String keyword in advancedtext['AND']) {
            if (keyword.isNotEmpty) {
              title.match('title', keyword, multiLine: true);
              description.match('description', keyword, multiLine: true);
            }
          }
          title.or(description);
          selector.and(title);
          
          for (String keyword in advancedtext['NOT']) {
            if (keyword.isNotEmpty) {
              selector.match('title', keyword, multiLine: true);
              selector.match('description', keyword, multiLine: true);
            }
          }

          for (String keyword in advancedtext['OR']) {
            if (keyword.isNotEmpty) {
              selector.or(mongo.where.match('title', keyword, multiLine: true));
              selector.or(
                  mongo.where..match('description', keyword, multiLine: true));
            }
          }*/
        }
        /*var macth = {
        {'\$all': advancedtext['AND']},
        {'\$all': 'values'},
        {'\$in': advancedtext['OR']}
      };*/

        selector.oneFrom('type', advancedtext['searchType']);
        advancedtext['originalOnly'] ? selector.eq('isOriginal', true) : {};
        advancedtext['R-18'] ? {} : selector.notExists("tags.R-18");
        advancedtext['likedOnly'] ? selector.eq('likeData', true) : {};
      } else {
        _isLoading.value = false;
        return;
      }
    } else if (finishedselector != null) {
      selector = finishedselector;
    } else {
      if (_searchController.text.isNotEmpty) {
        selector.eq('id', int.parse(_searchController.text));
      }
    }
    if (cancelevent) {
      cancelevent = false;
      return;
    }
    searchWork(selector).then((success) {
      if (success) {
        context.mounted
            ? resultDialog(context, 'Search', true, 'Found $reslength results!')
            : {};
        maxpage = (reslength / pagesize).ceil();
        changePage();
      } else {
        context.mounted
            ? resultDialog(
                context, 'Search', false, 'No matching results found!')
            : {};
      }
    });
  }

  Future<bool> searchWork(mongo.SelectorBuilder selector) async {
    onsearching = true;
    //widget.process.stdin.write('DATA||\n');
    //workInfos = await
    reslength = await widget.backupcollection.count(selector);
    if (reslength == 0) {
      _isLoading.value = false;
      onsearching = false;
      return false;
    } else {
      workInfos.clear();
      page = 1;
      widget.backupcollection
          .find(selector.sortBy('id', descending: true).excludeFields(['_id']))
          .forEach((info) {
        if (cancelevent) {
          cancelevent = false;
          return;
        }
        workInfos.add(info);
      }).then((_) => onsearching = false);
      //.toList();

      //print(result.length);
      /*int index = 0;
    List<dynamic> infos = [];
    searchResults.forEach((info) {
      if (index < pagesize) {
        infos.add(info);
      } else {
        workInfos.addEntries({page: infos}.entries);
        index = 0;
        infos.clear();
      }
    });*/
      return true;
    }
  }

  // 通信信息处理
  void dataHander(data) {}

  /// ************************* ///
  /// *********翻页控制********* ///
  /// ************************* ///
  void prevPage() {
    if (page > 1) {
      page -= 1;
      changePage();
    }
  }

  void jumpToPage() {
    int newpage =
        int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
    if (page == newpage) {
    } else if ((0 < newpage) && (newpage <= maxpage)) {
      page = newpage;
      changePage();
    } else {
      _pageController.text = '$page/$maxpage';
    }
  }

  void nextPage() {
    if (page < maxpage) {
      page += 1;
      changePage();
    }
  }

  void changePage() async {
    Timer.periodic(Durations.short2, (timer) {
      if (page * pagesize < reslength) {
        if (workInfos.length >= 8) {
          _isLoading.value = false;
          List<dynamic> info =
              workInfos.sublist((page - 1) * pagesize, page * pagesize);
          for (int i = 0; i < pagesize; i++) {
            workInfoNotifers[i].setInfoJson(info[i]);
          }
          timer.cancel();
        }
      } else {
        if (workInfos.length == reslength) {
          _isLoading.value = false;
          List<dynamic> info =
              workInfos.sublist((page - 1) * pagesize, reslength);
          for (int i = 0; i < pagesize; i++) {
            try {
              workInfoNotifers[i].setInfoJson(info[i]);
            } on RangeError {
              workInfoNotifers[i].value =
                  WorkInfo.fromJson(jsonDecode(defaultdata));
            }
          }
          timer.cancel();
        }
      }

      _pageController.text = '$page/$maxpage';
    });

    //print(page);
  }

  ///***********************///
  ///        构造界面        ///
  ///***********************///
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        // showinfo信号监听
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: Stack(children: [
              NotificationListener<ShowInfoNotification>(
                  onNotification: (notification) {
                    showingInfo.setInfo(notification.msg);
                    return true;
                  },
                  child: Row(spacing: 20, children: [
                    SizedBox(
                        width: 400,
                        height: 1080,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            //搜索控件
                            TextField(
                              controller: _searchController,
                              maxLength: 100,
                              decoration: InputDecoration(
                                labelText: "Ciallo~(∠・ω< )⌒☆",
                                icon: Icon(Icons.search),
                              ),
                            ),
                            /*Divider(),
                            ValueListenableBuilder(
                                valueListenable: searchType,
                                builder: (context, _searchType, child) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Id'),
                                            value: _searchType[0],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Uid'),
                                            value: _searchType[1],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Tag'),
                                            value: _searchType[2],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                        ])),*/
                            Divider(),
                            ElevatedButton.icon(
                              onPressed: searchAnalyzer,
                              icon: Icon(
                                Icons.search,
                                size: 30,
                              ),
                              label: Text('Search',
                                  style: TextStyle(fontSize: 20)),
                            ),
                            Divider(),
                            ElevatedButton(
                                onPressed: () {
                                  advancedSearch(context).then((context) {
                                    //TODO 高级搜索
                                    searchAnalyzer(context);
                                  });
                                },
                                child: Text('Advanced Search',
                                    style: TextStyle(fontSize: 20))),
                            Divider(),
                            //信息显示部件
                            NotificationListener<TagSearchNotification>(
                              onNotification: (notification) {
                                searchAnalyzer(
                                    null,
                                    mongo.where
                                        .exists('tags.${notification.tag}'));
                                return true;
                              },
                              child: InfoContainer(
                                workInfo: showingInfo,
                                config: widget.configs,
                              ),
                            )
                          ],
                        )),
                    /*
                    //收藏操作捕捉
                    NotificationListener<WorkBookMarkNotification>(
                        onNotification: (notification) {
                          if (notification.id != 114514 &&
                              notification.userName != 'Man') {
                            // 更新数据库
                            widget.pixivDb
                                .collection(notification.userName)
                                .updateOne(
                                    mongo.where.eq('id', notification.id),
                                    mongo.modify.set(
                                        'likeData', notification.bookmarked))
                                .then((res) =>
                                    res.isSuccess ? {} : throw 'update failed');
                            widget.backupcollection
                                .updateOne(
                                    mongo.where.eq('id', notification.id),
                                    mongo.modify.set(
                                        'likeData', notification.bookmarked))
                                .then((res) =>
                                    res.isSuccess ? {} : throw 'update failed');
                          }
                          return true;
                        },
                        child: */
                    // 作品展示网格
                    Flex(
                        direction: Axis.vertical,
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 1080,
                                //maxWidth: 1920,
                              ),
                              child: GridView.count(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 12 / 10, //高比宽
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[0]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[4]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[1]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[5]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[2]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[6]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[3]),
                                  ImageContainer(
                                      hostPath: widget.configs.savePath!,
                                      workInfoNotifier: workInfoNotifers[7]),
                                ],
                              )),
                          //翻页控件
                          Row(
                            spacing: 300,
                            children: [
                              ElevatedButton.icon(
                                onPressed: prevPage,
                                icon: Icon(
                                  Icons.navigate_before,
                                  size: 30,
                                ),
                                label: Text('Prev',
                                    style: TextStyle(fontSize: 20)),
                              ),
                              SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _pageController,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      labelText: "页码",
                                      //icon: Icon(Icons.search),
                                    ),
                                  )),
                              ElevatedButton.icon(
                                  onPressed: jumpToPage,
                                  icon: Icon(
                                    Icons.next_plan_outlined,
                                    size: 30,
                                  ),
                                  label: Text("Jump",
                                      style: TextStyle(fontSize: 20))),
                              ElevatedButton.icon(
                                  onPressed: nextPage,
                                  icon: Icon(
                                    Icons.navigate_next,
                                    size: 30,
                                  ),
                                  iconAlignment: IconAlignment.end,
                                  label: Text("Next",
                                      style: TextStyle(fontSize: 20))),
                            ],
                          )
                        ])
                  ])),
              // 加载指示器
              ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, value, child) {
                    return value
                        ? Positioned.fill(
                            child: Stack(children: [
                            ModalBarrier(
                              color: const Color.fromARGB(150, 158, 158, 158),
                              dismissible: true,
                              onDismiss: () => {
                                cancelevent = true,
                                _isLoading.value = false
                              },
                            ),
                            Center(
                              child: CircularProgressIndicator(
                                color: Colors.blueAccent,
                                strokeWidth: 6,
                                semanticsLabel: 'Loading......',
                              ),
                            ),
                          ]))
                        // 当不加载时不显示
                        : Container();
                  }),
            ])));
  }
}

/*
class _ImageContainerState extends State<ImageContainer>{
  /*
  List<String> imagePath = [];
  var imageInfo = {'imagecount':1};
  // include: id,type,title,description,count,uploadDate,isOriginal
  var autherInfo = {};
  // include: userId,username
  var userInfo = [];
  // include: islike
  var tags = {};
  // tags of this work
  var image = FileImage(File('images/default\.png'));
  void updateImage(List infos){
    imagePath = infos[0];
    imageInfo = infos[1];
    autherInfo = infos[2];
    userInfo = infos[3];
    tags = infos[4];
  }*/
  //var imagePath;
  //var imageInfo;
  /*@override
  void initState() {
    super.initState();
    imagePath = widget.workinfos.imagePath;
    //imagePath = widget.workinfos['imagePath'];
    imageInfo = widget.workinfos.imageInfo;
    //imageInfo = widget.workinfos['imageInfo'];
    // include: id,type,title,description,count,uploadDate,isOriginal
    /*
    var autherInfo = widget.workinfos[''];
    // include: userId,username
    var userInfo = widget.workinfos[''];
    // include: islike
    var tags = widget.workinfos[''];
    // tags of this work*/
  }
  void loadImage(String imagePath) async {
    var file = File(imagePath);
    var imfage = await file.readAsBytes();
    setState((){var _imfage = Image.memory(imfage);});
  }*/
  Future<File> _getImageFile() async {
    List<String> imagePath = widget.workinfos.imagePath;
    if (imagePath.isNotEmpty){
      return File(imagePath[0]);
    }
    else{
      // 若图片不存在就加载默认图片
      return File('images\\test.png');
    }
  }
  //var image = Image.asset('images\\test.png');
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 2, // 边框宽度
        ),
      ),
      width: (widget.width+5)*widget.scale,
      height: (widget.height+5)*widget.scale,
      // 异步加载图片
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<File>(
              future: _getImageFile(),
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Image.file(
                        snapshot.data!,
                        width: widget.width*widget.scale,
                        height: widget.height*widget.scale
                        ).animate().fade(duration: 500.ms);
                    }
                    else {return const Center(child: Text('Error loading image'));}
                  }
                  else {return const Center(child: CircularProgressIndicator());}
                }
              ),
          Positioned(
            top: 5,
            right: 5,
            width: 30,
            height: 20,
            child: Text(widget.workinfos.imageInfo['imagecount'].toString()),
          )
        ],
      )
    );
  }
}

     FutureBuilder<File>(
      future: _getImageFile(),
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Image.file(snapshot.data!);
          } else {
            return Center(child: Text('Error loading image'));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }  
        
          Widget build(BuildContext context){
    if (imagePath[0] != null){
      image  = FileImage(File(imagePath[0]));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // 边框颜色
              width: 2, // 边框宽度
            ),
          ),
          child: Image(
            image: image,
            width: widget.width*widget.scale,
            height: widget.height*widget.scale,
            alignment: Alignment.center
          )
        ),
        Positioned(
          top: 5,
          right: 5,
          width: 30,
          height: 20,
          child: Text(imageInfo['imagecount'].toString()),
        )
      ],
    );
  }
} */
