# network_to_file_image

This is a mixture of [FileImage] and [NetworkImage].
It will download the image from the url once, save it locally in the file system,
and then use it from there in the future.

In more detail:
 
Given a file and url of an image, it first tries to read it from the local file.
It decodes the given [File] object as an image, associating it with the given scale.

However, if the image doesn't yet exist as a local file, it fetches the given URL
from the network, associating it with the given scale, and then saves it to the local file.
The image will be cached regardless of cache headers from the server.

Notes:

 - If the provided url is null or empty, [NetworkToFileImage] will default
 to [FileImage]. It will read the image from the local file, and won't try to
 download it from the network.

 - If the provided file is null, [NetworkToFileImage] will default
 to [NetworkImage]. It will download the image from the network, and won't
 save it locally.

## Usage

### Import the package

First, add network_to_file_image [as a dependency](https://pub.dartlang.org/packages/network_to_file_image#-installing-tab-) in your pubspec.yaml

Then, import it:

    import 'package:network_to_file_image/network_to_file_image.dart';

### Use the package

If you also listed `path_provider` in your pubspec.yaml file:

    path_provider: ^0.4.1

Then you can create a file from a file name:

    Future<File> file(String filename) async {
      Directory dir = await getApplicationDocumentsDirectory();
      String pathName = p.join(dir.path, filename);
      return File(pathName);
    }
    
    var myFile = await file("myFileName.png"),

Then, create the image:

    Image(image: NetworkToFileImage(url: "http://example.com/someFile.png", file: myFile))

If you make debug=true it prints to the console whether the image was read from 
the file or fetched from the network:

    Image(image: NetworkToFileImage(url: "http://example.com/someFile.png", file: myFile, debug: true))    

Don't forget to check the [example tab](https://pub.dartlang.org/packages/network_to_file_image#-example-tab-).

## Tests

You can set mock files. Please see methods:

* `setMockFile(File file, Uint8List bytes)`
* `setMockUrl(String url, Uint8List bytes)`
* `clearMocks()`
* `clearMockFiles()`
* `clearMockUrls()`


## See also

  * flutter_image: https://pub.dartlang.org/packages/flutter_image
  * image_downloader: https://pub.dartlang.org/packages/image_downloader
  * cached_network_image: https://pub.dartlang.org/packages/cached_network_image
  * flutter_advanced_networkimage: https://pub.dartlang.org/packages/flutter_advanced_networkimage
