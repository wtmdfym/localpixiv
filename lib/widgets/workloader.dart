import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:provider/provider.dart';

/// 图片异步加载器
class ImageLoader extends StatelessWidget {
  const ImageLoader({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    // required this.cacheRate,
  });
  final String path;
  final int width;
  final int height;
  // final double cacheRate;

  @override
  Widget build(BuildContext context) {
    return Consumer<UIConfigUpdateNotifier>(
        builder: (context, configs, child) => FutureBuilder<ImageProvider>(
            future: imageFileLoader(
              path,
              width: width,
              height: height,
              cacheRate: configs.uiConfigs.imageCacheRate,
            ),
            builder:
                (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 400),
                    fadeOutDuration: const Duration(milliseconds: 250),
                    placeholder: AssetImage('images/loading.gif'),
                    image: snapshot.data!,
                    imageErrorBuilder: (context, error, stackTrace) {
                      if (error
                          .toString()
                          .contains('possibly due to invalid image data.')) {
                        File(path).delete();
                        return Text(
                          'Invalid image data! The image file may be corrupted. It will be deleted automatically.',
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 20),
                        );
                      } else {
                        return Text(
                          error.toString(),
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 20),
                        );
                      }
                    },
                  );
                } else {
                  return const Center(child: Text('Error loading image'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

/// 小说异步加载器
/// TODO
class NovelLoader extends StatelessWidget {
  const NovelLoader(
      {super.key, required this.coverImagePath, required this.title});
  final String coverImagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 400, height: 480, child: Text(title));
  }
}

class NovelDetialLoader extends StatelessWidget {
  const NovelDetialLoader({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content,
      style: TextStyle(fontSize: 24),
    );
  }
}
