import 'package:flutter/material.dart';
import 'dart:io';

// 异步加载图片
Future<dynamic> imageFileLoader(String? imagePath,
    [int? width, int? height]) async {
  ImageProvider image;
  //try {
  if (imagePath != null) {
    var file = File(imagePath);
    var exists = await file.exists();
    if (exists) {
      image = FileImage(file);
    } else {
      image = AssetImage('assets/images/test.png');
    }
  } else {
    // 若图片不存在就加载默认图片
    image = AssetImage('assets/images/test.png');
  }
  if (width != null && height != null) {
    return ResizeImage(image,
        width: width * 2, height: height * 2, policy: ResizeImagePolicy.fit);
  } else {
    return image;
  }
  //} catch (e) {
  //  return ResizeImage(AssetImage('assets/images/test.png'),
  //      policy: ResizeImagePolicy.fit);
  //}
}
