import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/tools.dart';

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
          width,
          height,
          cacheRate,
        ),
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return FadeInImage(
                fadeInDuration: const Duration(milliseconds: 400),
                fadeOutDuration: const Duration(milliseconds: 250),
                placeholder: AssetImage('assets/images/loading.gif'),
                image: snapshot.data!,
                imageErrorBuilder: (context, error, stackTrace) {
                  if (error
                      .toString()
                      .contains('possibly due to invalid image data.')) {
                    File(path).delete();
                  }
                  return Center(
                      child: Text(
                    '${error.toString()} It will be deleted automatically.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 20),
                  ));
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

class NovelLoader extends StatelessWidget {
  const NovelLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
