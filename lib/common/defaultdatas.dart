import '../models.dart';

const defaultworkdata = {
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
  "relative_path": ["what can I say"]
};
final WorkInfo defaultWorkInfo = WorkInfo.fromJson(defaultworkdata);

final Map<String, dynamic> defaultuserdata = {
  "userId": "114514",
  "userName": "Man",
  'profileImage': '',
  "userComment": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌+و(◠ڼ◠)٩ =꒰ঌ(🎀ᗜ v ᗜ 🌸)໒꒱✅\n" * 5,
  "workInfos": [
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
  ]
};
final UserInfo defaultUserInfo = UserInfo.fromJson(defaultuserdata);