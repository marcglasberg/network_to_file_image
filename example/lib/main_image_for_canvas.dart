import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

late Directory _appDocsDir;

void main() async {
  // You should get the Application Documents Directory only once.
  WidgetsFlutterBinding.ensureInitialized();
  _appDocsDir = await getApplicationDocumentsDirectory();

  runApp(MaterialApp(home: Demo()));
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class User {
  final String? filename;
  final String? url;

  User({
    this.filename,
    this.url,
  });
}

User user = User(
  filename: "flutter.png",
  url: "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png",
);

////////////////////////////////////////////////////////////////////////////////////////////////////

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ImageForCanvas example')),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: CustomPaint(
            painter: MyPainter(user, loadCallback: (_, __, ___) {
              setState(() {});
            }),
            child: Container(
              color: Colors.red.withOpacity(0.5),
              width: 300,
              height: 300,
            ),
          ),
        ),
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class MyPainter extends CustomPainter {
  final User user;
  final LoadCallback<User> loadCallback;

  MyPainter(
    this.user, {
    required this.loadCallback,
  });

  File fileFromDocsDir(String? filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  @override
  void paint(Canvas canvas, Size size) {
    //
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height), doAntiAlias: false);

    var imageForCanvas = _imageForCanvas();

    ui.Image? image = imageForCanvas.image(user);

    // While the image is loading it is null, so we don't paint anything.
    if (image != null) {
      canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    }
  }

  ImageForCanvas<User> _imageForCanvas() => ImageForCanvas<User>(
        //

        // Note: You can use any providers, like for example:
        // imageProviderSupplier: (User user) => NetworkImage(user.url),
        imageProviderSupplier: (User user) => NetworkToFileImage(
          file: fileFromDocsDir(user.filename),
          url: user.url,
        ),
        //

        // The key should uniquely identify the image.
        keySupplier: (User user) => user.url!,

        // The load callback will be called as soon as the image finishes
        // loading. Usually this should call setState on the widget that
        // uses this painter, so that the image can be displayed as soon
        // as it finishes loading.
        loadCallback: loadCallback,
      );

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
