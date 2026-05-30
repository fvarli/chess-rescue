// V1 board polish — emits assets/textures/board-grain.png, a 256×256
// transparent PNG with low-alpha speckles. Tiled over the board at ~3%
// effective opacity, it reads as "made of something" without overpowering
// the danger glow / mint bloom.
//
// Re-run: `dart run tool/generate_board_grain.dart` (deterministic, seeded).

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const size = 256;
  final image = img.Image(width: size, height: size, numChannels: 4);

  // Clear to fully transparent.
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Speckle density + intensity tuned to add board surface texture at
  // ~3 % effective opacity. Light specks (highlights) + sparse dark specks
  // (grit) read as natural grain rather than digital noise.
  final rng = math.Random(42); // seeded for reproducibility

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final r = rng.nextDouble();
      if (r < 0.10) {
        // Soft white grain (4–12 % alpha).
        final alpha = 10 + rng.nextInt(20);
        image.setPixelRgba(x, y, 255, 255, 255, alpha);
      } else if (r < 0.14) {
        // Sparse dark grit (3–8 % alpha).
        final alpha = 8 + rng.nextInt(12);
        image.setPixelRgba(x, y, 0, 0, 0, alpha);
      }
    }
  }

  final dir = Directory('assets/textures');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  const outPath = 'assets/textures/board-grain.png';
  File(outPath).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $outPath');
}
