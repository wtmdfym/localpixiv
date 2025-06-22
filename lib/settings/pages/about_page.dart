import 'package:flutter/material.dart';

import '../../localization/localization.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// About
class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/about';
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // localized text
  late String Function(String) _localizationMap;
  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).aboutPage;
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
              Text(_localizationMap('about')),
              Text(
                  "白洲梓适合结婚的十大理由：\n1、小梓在来到补习部前一直过着颠沛流离的生活，知道生活的艰辛苦楚，婚后一定不会大手大脚地花钱☺️\n2、在补习部，小梓从来没有放松警惕，这能有效保证婚后生活的安全🤩\n3、小梓是基沃托斯学生中的精英，和为师的孩子一定也是最优秀的😉\n4、作为冷面魔女，小梓的内心却并非冷漠，相反，她有一颗害羞内敛的心，正需要像为师这样的热忱的人来温暖🥰\n5、小梓内心单纯，需要一位生活经验丰富的大人来指引前路，而为师正是这样的人😋\n6、为师有颗孤独的内心，如果不是这样也不会成为傻卵ba厨了，而为师正需要小梓这样的少女来亲近，来温暖，来陪伴，这么可爱的女孩子，仅仅是看她笑一笑，我也能充实对生活的热情😍\n7、为师已经逻辑不清语无伦次了，就把这条作为第七条吧🥲\n8、没有第八条，十条理由就不算完整，正如没有小梓，我的人生就不算完整；所以我胡编乱造也要写上第八条，正如我拼尽全力也要留下小梓😘\n9、为师真的好喜欢小梓啊，小梓真的好可爱啊啊啊啊啊啊🤗\n10、小梓，我的小梓！没有你我怎么活啊😭😭🥰🥰😍😍😘😘")
            ])));
  }
}
