import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Use this `ImageForCanvas` class if you want to creates images to use with
/// Canvas. It will use the regular image cache from Flutter, and works with
/// NetworkToFileImage provider, or any other image providers.
///
/// In more detail:
///
/// ImageProviders can't be used directly with the `Canvas` object
/// of the `paint` method of a `CustomPainter`.
/// Use this to download and save in the cache images to use with canvas.
///
/// For example: Suppose a User object that contains url and filename
/// properties.
///
/// ```
/// var imageForCanvas = ImageForCanvas(
///        imageProviderSupplier: (User user) =>
///           NetworkToFileImage(file: user.file, url: user.url),
///        keySupplier: (User user) => usuario.filename,
///        loadCallback: (image, key) => setState((){}),
///      );
///
/// // While the image is downloading, this will return null.
/// var myImage = imageForCanvas.image(user);
///
/// if (myImage != null) {
///    canvas.drawImage(myImage, ...);
///    }
/// ```
///
class ImageForCanvas<T> {
  static final Map<Object, ui.Image> _images = {};

  static Object _identity(obj) => obj;

  ImageForCanvas({
    @required this.imageProviderSupplier,
    @required this.loadCallback,
    this.keySupplier = _identity,
  })  : assert(imageProviderSupplier != null),
        assert(keySupplier != null);

  final ImageProvider Function(T obj) imageProviderSupplier;

  final void Function(ImageInfo image, T key) loadCallback;

  final Object Function(T obj) keySupplier;

  void clearInternalCache() => _images.clear();

  ui.Image image(T obj) {
    var key = keySupplier(obj);
    var image = _images[key];

    if (image == null) {
      if (!_images.containsKey(key)) {
        _images[key] = null;

        ImageProvider imgProvider = imageProviderSupplier(key);

        final ImageStreamCompleter completer = PaintingBinding.instance.imageCache
            .putIfAbsent(imgProvider, () => imgProvider.load(imgProvider), onError: (_, __) {});

        ImageListener onImage = (ImageInfo image, bool synchronousCall) {
          _onImage(image, key);
        };

        ImageStreamListener listener = ImageStreamListener(onImage);

        completer.addListener(listener);
      }
    }

    return image;
  }

  void _onImage(ImageInfo image, T key) {
    _images[key] = image.image;
    if (loadCallback != null) loadCallback(image, key);
  }
}
