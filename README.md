[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

[![pub package](https://img.shields.io/pub/v/network_to_file_image.svg)](https://pub.dartlang.org/packages/network_to_file_image)

# network_to_file_image

This package combines `NetworkImage` and `FileImage` to:

* Download the image once from the URL,
* Save it to the local file system,
* Use the saved image from the file system from then on.

<br>

### In more detail:

Given a file and url of an image, it first tries to read it from the local file. It decodes the
given `File` object as an image, associating it with the given scale.

However, if the image doesn't yet exist as a local file, it fetches the given URL from the network,
associating it with the given scale, and then saves it to the local file. The image will be cached
regardless of cache headers from the server.

### Notes:

- If the provided url is null or empty, `NetworkToFileImage` will default to `FileImage`. It will
  read the image from the local file, and won't try to download it from the network.
            

- If the provided file is null, `NetworkToFileImage` will default to `NetworkImage`. It will
  download the image from the network, and won't save it locally.

## Use the package

Import `path_provider` in your pubspec.yaml file:

    path_provider: ^2.1.1 

Then use it to create a `File` from a file name:

    Future<File> file(String filename) async {
      Directory dir = await getApplicationDocumentsDirectory();
      String pathName = p.join(dir.path, filename);
      return File(pathName);
    }
    
    var myFile = await file("myFileName.png"),

Then, create the image:

```
Image(image: 
   NetworkToFileImage(
      url: "https://example.com/someFile.png", 
      file: myFile,
   )
)
```

If you make `debug: true` it prints to the console whether the image was read from the file or
fetched from the network:

```
Image(image: 
   NetworkToFileImage(
      url: "https://example.com/someFile.png", 
      file: myFile, 
      debug: true,
   )
)    
```

Try running
the <a href="https://github.com/marcglasberg/network_to_file_image/blob/master/example/lib/main.dart">
NetworkToFileImage example</a>.

### Important:

The directory where you want to save the image must already exist in the local disk. Otherwise, the
image won't be saved.

## Canvas

You can also load images to use with the `Canvas` object of the `paint` method of a `CustomPainter`.

ImageProviders can't be used directly with the `Canvas` object, but you can use the
provided `ImageForCanvas` class.

For example: Suppose a `User` object that contains `url` and `filename` properties:

```
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

It will use the regular image cache from Flutter, and works not only with `NetworkToFileImage`
provider, but any other image providers.

Try running
the <a href="https://github.com/marcglasberg/network_to_file_image/blob/master/example/lib/main_image_for_canvas.dart">
ImageForCanvas example</a>.

## Tests

You can set mock files (local and in the network). Please see methods:

* `setMockFile(File file, Uint8List bytes)`
* `setMockUrl(String url, Uint8List bytes)`
* `clearMocks()`
* `clearMockFiles()`
* `clearMockUrls()`

Your mocked urls are usually only seen by the `NetworkToFileImage` class. However, you may override
the default Dart http methods so that these urls are visible to other ImageProviders.

To that end, simply call this method:

```
NetworkToFileImage.startHttpOverride();
```                                                             

You can stop the http override by calling:

```
NetworkToFileImage.stopHttpOverride();
```                                                            

***

## By Marcelo Glasberg

<a href="https://glasberg.dev">_glasberg.dev_</a>
<br>
<a href="https://github.com/marcglasberg">_github.com/marcglasberg_</a>
<br>
<a href="https://www.linkedin.com/in/marcglasberg/">_linkedin.com/in/marcglasberg/_</a>
<br>
<a href="https://twitter.com/glasbergmarcelo">_twitter.com/glasbergmarcelo_</a>
<br>
<a href="https://stackoverflow.com/users/3411681/marcg">
_stackoverflow.com/users/3411681/marcg_</a>
<br>
<a href="https://medium.com/@marcglasberg">_medium.com/@marcglasberg_</a>
<br>

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding
  constraints</a>

*The Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/themed">themed</a>
* <a href="https://pub.dev/packages/bdd_framework">bdd_framework</a>
* <a href="https://pub.dev/packages/tiktoken_tokenizer_gpt4o_o1">
  tiktoken_tokenizer_gpt4o_o1</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> 
  (versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> 
  (versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> 
  (versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 
