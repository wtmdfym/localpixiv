import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/tools.dart';

/// 图片异步加载器
class ImageLoader extends StatelessWidget {
  const ImageLoader({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    required this.cacheRate,
  });
  final String path;
  final int width;
  final int height;
  final double cacheRate;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
        future: imageFileLoader(
          path,
          width: width,
          height: height,
          cacheRate: cacheRate,
        ),
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
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
                      style: TextStyle(color: Colors.redAccent),
                    );
                  } else {
                    return Text(
                      error.toString(),
                      style: TextStyle(color: Colors.redAccent),
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
        });
  }
}

/// 小说异步加载器
/// TODO
class NovelLoader extends StatelessWidget {
  const NovelLoader({
    super.key,
    required this.coverImagePath,
    required this.title,
    required this.width,
    required this.height,
    required this.cacheRate,
  });

  final String coverImagePath;
  final String title;
  final int width;
  final int height;
  final double cacheRate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageLoader(
            path: coverImagePath,
            width: width,
            height: height,
            cacheRate: cacheRate),
        Positioned(bottom: 8, child: Text(title))
      ],
    );
  }
}

class NovelDetialLoader extends StatelessWidget {
  const NovelDetialLoader({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content,
    );
  }
}
