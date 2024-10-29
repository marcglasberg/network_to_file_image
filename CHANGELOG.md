## 7.0.0

* Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

## 6.0.1

* Breaking change: Loading errors are now `NetworkToFileImageLoadException` instead
  of `NetworkImageLoadException`. This change is unlikely to affect you.

* Better error handling when both the url and the file are null, or when the file doesn't
  exist
  locally, but the url was not provided.

## 5.0.2

* Flutter 3.16.0 compatible.

## 4.0.1

* Flutter 3.0.0 compatible.

## 3.1.0

* Now `ImageForCanvas.imageProviderSupplier` may return a null `ImageProvider`.

## 3.0.3

* Fixed problem with
  errorBuilder (https://github.com/marcglasberg/network_to_file_image/issues/27).

## 3.0.2

* Compatible with Flutter 2.5.

## 3.0.0

* Docs improvement.

## 2.3.6

* Improving compatibility with Flutter 1.22.

## 2.3.2

* Upgrade: Flutter 1.20.
* Example: main_image_for_canvas.dart

## 2.3.0

* Upgrade: Flutter 1.17.

## 2.2.8

* Better example (appDocsDir is read only once, during app initialization).

## 2.2.4

* Http override (mock urls visible to the whole app).

## 2.2.1

* Upgrade: Dart 2.7 (as per https://github.com/flutter/flutter/pull/41415).

## 2.1.5

* ImageForCanvas.

## 2.0.7

* ErrorDescription.

## 2.0.2

* Commented out the informationCollector, until version 1.7.8.

## 2.0.0

* Reverted back to stable Flutter version 1.5.X.

## 1.7.8

* Fixed for versions 1.7.8 and up.

## 1.0.4

* This version works for the stable Flutter version 1.5.X.

## 1.0.3

* Allow mock urls.

## 1.0.2

* Details.

## 1.0.1

* Allow mock files.

## 1.0.0

* Tested thoroughly.

## 0.0.2

* Corrected changelog and license.

## 0.0.1

* Reads from the file, or fetches from the network and saves to the file.
