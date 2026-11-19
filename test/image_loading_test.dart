import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

Future<ImageInfo> loadImage(ImageProvider provider) async {
  final result = Completer<ImageInfo>();
  final stream = provider.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener(
    (image, isSynchronous) => result.complete(image),
    onError: (Object error, StackTrace? stack) => result.completeError(error, stack),
  );
  stream.addListener(listener);
  try {
    return await result.future;
  } finally {
    stream.removeListener(listener);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Uint8List png;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('network-image-test-');
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const Color(0xFF123456), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(2, 1);
    png = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
  });
  tearDown(() async {
    NetworkToFileImage.clearMocks();
    PaintingBinding.instance.imageCache.clear();
    await directory.delete(recursive: true);
  });

  test('a local image is decoded before attempting the network', () async {
    final file = File('${directory.path}/local.png');
    await file.writeAsBytes(png);
    NetworkToFileImage.setMockUrl('https://example.com/local.png', Uint8List(0));
    final image = await loadImage(
        NetworkToFileImage(file: file, url: 'https://example.com/local.png'));
    expect([image.image.width, image.image.height], [2, 1]);
    image.dispose();
  });

  test('a downloaded image is saved and can be loaded locally', () async {
    final file = File('${directory.path}/download.png');
    NetworkToFileImage.setMockUrl('https://example.com/download.png', png);
    final image = await loadImage(
        NetworkToFileImage(file: file, url: 'https://example.com/download.png'));
    expect(image.image.width, 2);
    image.dispose();
    for (var attempt = 0; attempt < 100; attempt++) {
      if (await file.exists() && await file.length() == png.length) break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(await file.readAsBytes(), png);
    NetworkToFileImage.clearMocks();
    PaintingBinding.instance.imageCache.clear();
    final local = await loadImage(NetworkToFileImage(file: file));
    expect(local.image.height, 1);
    local.dispose();
  });

  test('a failed decode evicts the memory cache and permits recovery', () async {
    final file = File('${directory.path}/invalid.png');
    NetworkToFileImage.setMockFile(file, Uint8List.fromList([1, 2, 3]));
    final provider = NetworkToFileImage(file: file);
    await expectLater(loadImage(provider), throwsA(isA<Exception>()));
    await Future<void>.delayed(Duration.zero);
    expect(PaintingBinding.instance.imageCache.containsKey(provider), isFalse);
    NetworkToFileImage.setMockFile(file, png);
    final recovered = await loadImage(provider);
    expect(recovered.image.width, 2);
    recovered.dispose();
  });

  test('canvas loading reports completion and keeps the loaded image', () async {
    final file = File('${directory.path}/canvas.png');
    NetworkToFileImage.setMockFile(file, png);
    final result = Completer<void>();
    final canvasImage = ImageForCanvas<String>(
      imageProviderSupplier: (_) => NetworkToFileImage(file: file),
      loadCallback: (_, object, key) {
        expect(object, 'photo');
        result.complete();
      },
    );
    canvasImage.clearInternalCache();
    expect(canvasImage.image('photo'), isNull);
    await result.future;
    expect(canvasImage.image('photo')!.width, 2);
    canvasImage.clearInternalCache();
  });

  test('canvas loading accepts an absent provider', () {
    final canvasImage = ImageForCanvas<String>(
      imageProviderSupplier: (_) => null,
      loadCallback: (_, object, key) => fail('No image should be delivered'),
    );
    canvasImage.clearInternalCache();
    expect(canvasImage.image('missing'), isNull);
    canvasImage.clearInternalCache();
  });
}
