import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

late Directory _appDocsDir;

void main() async {
  // You should get the Application Documents Directory only once.
  WidgetsFlutterBinding.ensureInitialized();
  _appDocsDir = await getApplicationDocumentsDirectory();

  runApp(MaterialApp(home: Demo()));
}

File fileFromDocsDir(String filename) {
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}

class Demo extends StatefulWidget {
  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  int count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('NetworkToFileImage example')),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              _image(),
              const SizedBox(height: 30),
              _button(),
            ],
          ),
        ),
      );

  Widget _image() {
    return Image(
      key: ValueKey(count),
      image: NetworkToFileImage(
        url: "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png",
        file: fileFromDocsDir("flutter.png"),
        debug: true,
      ),
      errorBuilder: (context, error, stackTrace) {
        return Text('Download image failed.');
      },
    );
  }

  Widget _button() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          count++;
        });
      },
      child: Text('Rebuild image widget!'),
    );
  }
}
