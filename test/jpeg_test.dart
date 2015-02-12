part of image_test;

void defineJpegTests() {
  Io.File script = new Io.File(Io.Platform.script.toFilePath());
  String path = script.parent.path;

  Io.Directory dir = new Io.Directory(path + '/res/jpg');
  List files = dir.listSync();

  List<int> toRGB(int pixel) =>
      [getRed(pixel), getGreen(pixel), getBlue(pixel)];

  group('JPEG', () {
    for (var f in files) {
      if (f is! Io.File || !f.path.endsWith('.jpg')) {
        continue;
      }

      String name = f.path.split(new RegExp(r'(/|\\)')).last;
      test('$name', () {
        List<int> bytes = f.readAsBytesSync();
        Image image = new JpegDecoder().decodeImage(bytes);
        if (image == null) {
          throw new ImageException('Unable to decode JPEG Image: $name.');
        }

        List<int> png = new PngEncoder().encodeImage(image);
        new Io.File(path + '/out/jpg/${name}.png')
              ..createSync(recursive: true)
              ..writeAsBytesSync(png);
      });
    }

    test('decode/encode', () {
      List<int> bytes = new Io.File(path + '/res/jpg/testimg.png').readAsBytesSync();
      Image png = new PngDecoder().decodeImage(bytes);
      expect(toRGB(png.getPixel(0, 0)), [48, 47, 45]);

      bytes = new Io.File(path + '/res/jpg/testimg.jpg').readAsBytesSync();

      // Decode the image from file.
      Image image = new JpegDecoder().decodeImage(bytes);
      expect(image.width, equals(227));
      expect(image.height, equals(149));

      /*for (int y = 0; y < image.height; ++y) {
        for (int x = 0; x < image.width; ++x) {
          expect(image.getPixel(x, y), equals(png.getPixel(x, y)),
              reason: '$x $y : ${toRGB(image.getPixel(x, y))} != '
                      '${toRGB(png.getPixel(x, y))}');
        }
      }*/

      // Encode the image to Jpeg
      List<int> jpg = new JpegEncoder().encodeImage(image);

      // Decode the encoded jpg.
      Image image2 = new JpegDecoder().decodeImage(jpg);

      // We can't exactly do a byte-level comparison since Jpeg is lossy.
      expect(image2.width, equals(227));
      expect(image2.height, equals(149));
    });
  });
}
