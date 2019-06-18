library network_to_file_image;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This is a mixture of [FileImage] and [NetworkImage].
/// It will download the image from the url once, save it locally in the file system,
/// and then use it from there in the future.
///
/// In more detail:
///
/// Given a file and url of an image, it first tries to read it from the local file.
/// It decodes the given [File] object as an image, associating it with the given scale.
///
/// However, if the image doesn't yet exist as a local file, it fetches the given URL
/// from the network, associating it with the given scale, and then saves it to the local file.
/// The image will be cached regardless of cache headers from the server.
///
/// Notes:
///
/// - If the provided url is null or empty, [NetworkToFileImage] will default
/// to [FileImage]. It will read the image from the local file, and won't try to
/// download it from the network.
///
/// - If the provided file is null, [NetworkToFileImage] will default
/// to [NetworkImage]. It will download the image from the network, and won't
/// save it locally.
///
/// - If you make debug=true it will print to the console whether the image was
/// read from the file or fetched from the network.
///
/// ## Tests
///
/// You can set mock files. Please see methods:
///
/// * `setMockFile(File file, Uint8List bytes)`
/// * `setMockUrl(String url, Uint8List bytes)`
/// * `clearMocks()`
/// * `clearMockFiles()`
/// * `clearMockUrls()`
///
/// ## See also:
///
///  * flutter_image: https://pub.dartlang.org/packages/flutter_image
///  * image_downloader: https://pub.dartlang.org/packages/image_downloader
///  * cached_network_image: https://pub.dartlang.org/packages/cached_network_image
///  * flutter_advanced_networkimage: https://pub.dartlang.org/packages/flutter_advanced_networkimage
class NetworkToFileImage extends ImageProvider<NetworkToFileImage> {
  //
  const NetworkToFileImage({
    @required this.file,
    @required this.url,
    this.scale = 1.0,
    this.headers,
    this.debug = false,
    ProcessError processError,
  })  : assert(file != null || url != null),
        assert(scale != null);

  final File file;
  final String url;
  final double scale;
  final Map<String, String> headers;
  final bool debug;

  static final Map<String, Uint8List> _mockFiles = {};
  static final Map<String, Uint8List> _mockUrls = {};

  /// You can set mock files. It searches for an exact file.path (string comparison).
  /// For example, to set an empty file: setMockFile(File("photo.png"), null);
  static setMockFile(File file, Uint8List bytes) {
    assert(file != null);
    _mockFiles[file.path] = bytes;
  }

  /// You can set mock urls. It searches for an exact url (string comparison).
  static setMockUrl(String url, Uint8List bytes) {
    assert(url != null);
    _mockUrls[url] = bytes;
  }

  static clearMocks() {
    clearMockFiles();
    clearMockUrls();
  }

  static clearMockFiles() {
    _mockFiles.clear();
  }

  static clearMockUrls() {
    _mockUrls.clear();
  }

  @override
  Future<NetworkToFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkToFileImage>(this);
  }

  @override
  ImageStreamCompleter load(NetworkToFileImage key) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: (StringBuffer information) {
          information.writeln('Image provider: $this');
          information.writeln('File: ${file?.path}');
          information.writeln('Url: $url');
        });
  }

  Future<ui.Codec> _loadAsync(NetworkToFileImage key) async {
    assert(key == this);
    // ---

    Uint8List bytes;

    // Reads a MOCK file.
    if (file != null && _mockFiles.containsKey(file.path)) {
      bytes = _mockFiles[file.path];
    }

    // Reads from the local file.
    else if (file != null && _ifFileExistsLocally()) {
      bytes = await _readFromTheLocalFile();
    }

    // Reads from the MOCK network and saves it to the local file.
    else if (url != null && url.isNotEmpty && _mockUrls.containsKey(url)) {
      bytes = await _downloadFromTheMockNetworkAndSaveToTheLocalFile();
    }

    // Reads from the network and saves it to the local file.
    else if (url != null && url.isNotEmpty) {
      bytes = await _downloadFromTheNetworkAndSaveToTheLocalFile();
    }

    // ---

    // Empty file.
    if ((bytes != null) && (bytes.lengthInBytes == 0)) bytes = null;

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  bool _ifFileExistsLocally() => file.existsSync();

  Future<Uint8List> _readFromTheLocalFile() async {
    if (debug) print("Reading image file: ${file?.path}");
    return await file.readAsBytes();
  }

  static final HttpClient _httpClient = HttpClient();

  Future<Uint8List> _downloadFromTheNetworkAndSaveToTheLocalFile() async {
    assert(url != null && url.isNotEmpty);
    if (debug) print("Fetching image from: $url");
    // ---

    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw Exception('HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) throw Exception('NetworkImage is an empty file: $resolved');

    if (file != null) saveImageToTheLocalFile(bytes);

    return bytes;
  }

  Future<Uint8List> _downloadFromTheMockNetworkAndSaveToTheLocalFile() async {
    assert(url != null && url.isNotEmpty);
    if (debug) print("Fetching image from: $url");
    // ---

    final Uri resolved = Uri.base.resolve(url);
    Uint8List bytes = _mockUrls[url];
    if (bytes.lengthInBytes == 0) throw Exception('NetworkImage is an empty file: $resolved');
    if (file != null) saveImageToTheLocalFile(bytes);
    return bytes;
  }

  void saveImageToTheLocalFile(Uint8List bytes) async {
    if (debug) print("Saving image to file: ${file?.path}");
    file.writeAsBytes(bytes, flush: true);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkToFileImage typedOther = other;
    return url == typedOther.url &&
        file?.path == typedOther.file?.path &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, file?.path, scale);

  @override
  String toString() => '$runtimeType("${file?.path}", "$url", scale: $scale)';
}

typedef ProcessError = void Function(dynamic error);
