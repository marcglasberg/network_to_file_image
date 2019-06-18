import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

String flutterLogoUrl =
    "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png";

String flutterLogoFileName = "flutter.png";

void main() async {
  runApp(
    MaterialApp(
      home: Demo(
        url: flutterLogoUrl,
        file: await file(flutterLogoFileName),
      ),
    ),
  );
}

Future<File> file(String filename) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String pathName = p.join(dir.path, filename);
  return File(pathName);
}

class Demo extends StatelessWidget {
  final String url;
  final File file;

  const Demo({Key key, this.url, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Network to file image example')),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Image(
          image: NetworkToFileImage(url: url, file: file, debug: true),
        ),
      ),
    );
  }
}
