[![pub package](https://img.shields.io/pub/v/network_to_file_image.svg)](https://pub.dartlang.org/packages/network_to_file_image)

# network_to_file_image

This is a mixture of `FileImage` and `NetworkImage`.
It will download the image from the url once, save it locally in the file system,
and then use it from there in the future.

**In more detail:**
 
Given a file and url of an image, it first tries to read it from the local file.
It decodes the given `File` object as an image, associating it with the given scale.

However, if the image doesn't yet exist as a local file, it fetches the given URL
from the network, associating it with the given scale, and then saves it to the local file.
The image will be cached regardless of cache headers from the server.

Notes:

 - If the provided url is null or empty, `NetworkToFileImage` will default
 to `FileImage`. It will read the image from the local file, and won't try to
 download it from the network.

 - If the provided file is null, `NetworkToFileImage` will default
 to `NetworkImage`. It will download the image from the network, and won't
 save it locally.

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

If you make `debug: true` it prints to the console whether the image was read from 
the file or fetched from the network:

    Image(image: NetworkToFileImage(url: "http://example.com/someFile.png", file: myFile, debug: true))    

Don't forget to check the [example tab](https://pub.dartlang.org/packages/network_to_file_image#-example-tab-).

## Canvas

You can also load images to use with the `Canvas` object of the `paint` method of a `CustomPainter`. 

ImageProviders can't be used directly with the `Canvas` object, 
but you can use the provided `ImageForCanvas` class.
 
For example: Suppose a `User` object that contains `url` and `filename` properties:

 ```dart
 var imageForCanvas = ImageForCanvas<User>(
        imageProviderSupplier: (User user) => NetworkToFileImage(file: user.file, url: user.url),
        keySupplier: (User user) => user.filename,
        loadCallback: (image, obj, key) => setState((){}),
      );

 // While the image is downloading, this will return null.
 var myImage = imageForCanvas.image(user);

 if (myImage != null) {
    canvas.drawImage(myImage, ...);
    }
 ```

It will use the regular image cache from Flutter, and works not only with `NetworkToFileImage` provider, 
but any other image providers.


## Tests

You can set mock files. Please see methods:

* `setMockFile(File file, Uint8List bytes)`
* `setMockUrl(String url, Uint8List bytes)`
* `clearMocks()`
* `clearMockFiles()`
* `clearMockUrls()`

## See also

  * <a href="https://pub.dev/packages/flutter_image">flutter_image</a>
  * <a href="https://pub.dev/packages/image_downloader">image_downloader</a>
  * <a href="https://pub.dev/packages/cached_network_image">cached_network_image</a>
  * <a href="https://pub.dev/packages/flutter_advanced_networkimage">flutter_advanced_networkimage</a>  
  * <a href="https://pub.dev/packages/extended_image">extended_image</a>  

***

*The Flutter packages I've authored:* 
* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18_extension">i18_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a> 
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a> 
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>

---<br>_Marcelo Glasberg:_<br>_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>
