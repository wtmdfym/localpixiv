import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localpixiv/widgets/workdisplayer.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/common/custom_notifier.dart';
import 'package:localpixiv/models.dart';
import 'package:mongo_dart/mongo_dart.dart' as abab;

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
/*{
  "type": "illust",
  "id": 119867734,
  "title": "海開きらりんっ！✨🌊",
  "description": "お久しぶりです！これからも頑張って描いていきます！",
  "tags": {
    "ロリ": "萝莉",
    "水着": "泳装",
    "女の子": "女孩子",
    "ケモミミ": "兽耳",
    "オリジナル": "原创",
    "太もも": "大腿",
    "猫耳": "cat ears",
    "海": "sea",
    "浮き輪": "游泳圈",
    "イラスト": "插画"
  },
  "userId": "17596327",
  "username": "ことりーふ",
  "uploadDate": "2024-06-22T10:05:00+00:00",
  "likeData": false,
  "isOriginal": true,
  "imageCount": 1,
  "relative_path": [
    "picture/17596327/119867734_p0.jpg"
  ]
}*/

class Viewer extends StatefulWidget {
  const Viewer({super.key, required this.db
      //required this.channel,
      });
  final abab.Db db;
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
  bool cancelevent = false;
  List<dynamic> searchedInfos = [];
  List<WorkInfoNotifier> workInfoNotifers = [
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata))),
    //WorkInfoNotifier(WorkInfo(id: 1,imagePath: ['images/test.png'],imageInfo: {'imagecount':1}))
  ];
  WorkInfoNotifier showingInfo =
      WorkInfoNotifier(WorkInfo.fromJson(jsonDecode(defaultdata)));
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');
  /*ValueNotifier<List<bool>> searchType =
      ValueNotifier([true, false, false]); //id  uid tag*/
  List<dynamic> workInfos = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  changeImage() {
    if (page == 1) {
      page +=
          1; //C:\\Users\\Administrator\\Desktop\\New folder\\b4fa79cb-d8ca-47dd-9d5a-b1f39bb1212b.jpeg
      _pageController.text = page.toString();
      workInfoNotifers[0].setimagepath(['E:/pixiv/picture/24838/44382341.gif']);
      workInfoNotifers[0].setimageCount(23);
      workInfoNotifers[0].settitle('ababab');
      //workInfoNotifers[1].setimagepath(['E:/pixiv/picture/89357/105314582_p2.png']);
    } else {
      page -= 1;
      _pageController.text = page.toString();
      workInfoNotifers[0].setimagepath([
        'C:\\Users\\Administrator\\Desktop\\New folder\\daf9fd58289eefc1be.png'
      ]);
      workInfoNotifers[0].setimageCount(5);
      workInfoNotifers[0].settitle('海開きらりんっ！✨🌊');
      //workInfoNotifers[1].setimagepath(['E:/pixiv/picture/89357/105367593_p0.png']);
    }
  }

  /// ************************* ///
  /// *********搜索控制********* ///
  /// ************************* ///
  void searchAnalyzer() {
    _isLoading.value = true;
    String text = _searchController.text;
    if (cancelevent) {
      cancelevent = false;
      return;
    }
    searchWork(text);
  }

  void searchWork(String searchText) async {
    List<dynamic> result = [];
    if (cancelevent) {
      cancelevent = false;
      return;
    }
    if (searchText.isEmpty) {
      var collection = widget.db.collection('backup of pixiv infos');
      if (cancelevent) {
        cancelevent = false;
        return;
      }
      var tresult = collection.find(abab.where
          .exists('id')
          // wrong .notExists('{"tags":{"R-18": null}}')
          .sortBy('id', descending: true));
      if (cancelevent) {
        cancelevent = false;
        return;
      }
      result = await tresult.toList();
    } else {}
    //print(result.length);
    maxpage = (result.length / 8).ceil();
    if (cancelevent) {
      cancelevent = false;
      return;
    }
    workInfos = result;
    _isLoading.value = false;
    //page = 18;
    changePage();
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

  void changePage() {
    List<dynamic> info;
    if (page * 8 < workInfos.length) {
      info = workInfos.sublist((page - 1) * 8, page * 8);
    } else {
      info = workInfos.sublist((page - 1) * 8, workInfos.length);
    }
    for (int i = 0; i < 8; i++) {
      try {
        workInfoNotifers[i].setInfoJson(info[i]);
      } on RangeError {
        workInfoNotifers[i].setInfoJson(jsonDecode((defaultdata)));
      }
    }
    _pageController.text = '$page/$maxpage';
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
                                onPressed: () => advancedSearch(context),
                                child: Text('Advanced Search',
                                    style: TextStyle(fontSize: 20))),
                            Divider(),
                            InfoContainer(workInfo: showingInfo),
                          ],
                        )),
                    Flex(
                        direction: Axis.vertical,
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 1080,
                                //maxWidth: 1920,
                                //minHeight: 400
                              ),
                              child: GridView.count(
                                scrollDirection: Axis.horizontal,
                                //clipBehavior: Clip.antiAlias,
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 11 / 10, //高比宽
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[0]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[4]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[1]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[5]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[2]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[6]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[3]),
                                  ImageContainer(
                                      workInfoNotifier: workInfoNotifers[7]),
                                ],
                              )),
                          Row(
                            spacing: 200,
                            children: [
                              SizedBox(
                                  width: 200,
                                  child: ElevatedButton.icon(
                                    onPressed: prevPage,
                                    icon: Icon(
                                      Icons.navigate_before,
                                      size: 30,
                                    ),
                                    label: Text('Prev',
                                        style: TextStyle(fontSize: 20)),
                                  )),
                              SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _pageController,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      labelText: "页码",
                                      //icon: Icon(Icons.search),
                                    ),
                                  )),
                              SizedBox(
                                  width: 200,
                                  //height: 30,
                                  child: ElevatedButton.icon(
                                      onPressed: jumpToPage,
                                      icon: Icon(
                                        Icons.next_plan_outlined,
                                        size: 30,
                                      ),
                                      label: Text("Jump",
                                          style: TextStyle(fontSize: 20)))),
                              SizedBox(
                                  width: 200,
                                  child: ElevatedButton.icon(
                                      onPressed: nextPage,
                                      icon: Icon(
                                        Icons.navigate_next,
                                        size: 30,
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      label: Text("Next",
                                          style: TextStyle(fontSize: 20)))),
                            ],
                          )
                        ])
                  ])),
              // 加载指示器的蒙层
              ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, value, child) {
                    return value
                        ? Positioned.fill(
                            child: Stack(children: [
                            ModalBarrier(
                              color: const Color.fromARGB(153, 91, 84, 84),
                              dismissible: true,
                              onDismiss: () => {
                                cancelevent = true,
                                _isLoading.value = false
                              },
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                          ]))
                        : Container();
                  }), // 当不加载时不显示蒙层
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
  var image = FileImage(File('images/test.png'));
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
