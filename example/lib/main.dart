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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _image(),
                const SizedBox(height: 30),
                _button(),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. This prints debug messages to the console:'),
                    SizedBox(height: 6),
                    Text('NetworkToFileImage(... debug: true);', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 35),
                    //
                    Text('2. Rebuilding or hot-reloading should not read the image again, '
                        'as the image is cached.'),
                    SizedBox(height: 35),
                    //
                    Text('3. Restarting the app should, however, say something like:'),
                    SizedBox(height: 6),
                    Text('Reading image file: /data/user/0/xxx/app_flutter/flutter.png',
                        style: TextStyle(fontSize: 10)),
                    SizedBox(height: 35),
                    //
                    Text('4. Changing the filename here from:'),
                    SizedBox(height: 6),
                    Text('file: fileFromDocsDir("flutter.png")', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 12),
                    Text('To:'),
                    SizedBox(height: 6),
                    Text('file: fileFromDocsDir("flutterX.png")', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 10),
                    Text('And restarting the app, should print this to the console:'),
                    SizedBox(height: 6),
                    Text('Fetching image from: https://.../Google-flutter-logo.png',
                        style: TextStyle(fontSize: 10)),
                    Text('Saving image to file: /data/user/0/xxx/app_flutter/flutterX.png',
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
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
      child: Text('Rebuild image widget'),
    );
  }
}
