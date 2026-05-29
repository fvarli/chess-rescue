// Chess Rescue — store asset generator (Phase 28).
//
// Reproducible, pure-Dart renderer for the brand mark "The Trajectory":
// a coral danger node, a tapered coral→mint leap arc with a subtle knight's-
// elbow, and a mint relief bloom, on the deep #0D0E12 field. Outputs the app
// icon (master / adaptive foreground / background), the Play 512 icon, and a
// text-free v1 feature graphic. See docs/store-assets-spec.md / brand-direction.md.
//
// Run:  dart run tool/generate_store_assets.dart
//
// Not part of the test suite (lives under tool/). No gameplay/runtime impact.

import 'dart:io';

import 'package:image/image.dart' as img;

// D4 palette
const _field = [13, 14, 18]; // #0D0E12
const _coral = [255, 90, 76]; // #FF5A4C
const _mint = [94, 226, 192]; // #5EE2C0

const _ss = 2; // supersample factor → downsample for clean antialiased edges

img.ColorRgba8 _lerp(List<int> a, List<int> b, double t, int alpha) {
  int c(int x, int y) => (x + (y - x) * t).round().clamp(0, 255);
  return img.ColorRgba8(c(a[0], b[0]), c(a[1], b[1]), c(a[2], b[2]), alpha);
}

double _quad(double p0, double c, double p2, double t) {
  final u = 1 - t;
  return u * u * p0 + 2 * u * t * c + t * t * p2;
}

// Two quadratic segments meeting at the knight's-elbow (normalized [0,1] box):
// coral node → elbow → mint bloom.
const _segs = [
  [
    [0.26, 0.74],
    [0.30, 0.50],
    [0.52, 0.50],
  ],
  [
    [0.52, 0.50],
    [0.64, 0.40],
    [0.74, 0.26],
  ],
];

/// Draw the mark into [im], mapping the normalized box to (ox,oy,box).
/// [glow] = the soft under-layer (larger radii, lower alpha) to be blurred.
void _drawMark(img.Image im, double ox, double oy, double box, bool glow) {
  void disc(double nx, double ny, double r, img.Color color) {
    img.fillCircle(
      im,
      x: (ox + nx * box).round(),
      y: (oy + ny * box).round(),
      radius: r.round().clamp(1, 1 << 20),
      color: color,
      antialias: true,
    );
  }

  const n = 140;
  for (var seg = 0; seg < _segs.length; seg++) {
    final p0 = _segs[seg][0], c = _segs[seg][1], p2 = _segs[seg][2];
    for (var i = 0; i <= n; i++) {
      final lt = i / n;
      final gt = (seg + lt) / _segs.length; // global 0..1 along the whole arc
      final baseR = (0.055 - 0.033 * gt) * box; // taper thick → thin
      disc(
        _quad(p0[0], c[0], p2[0], lt),
        _quad(p0[1], c[1], p2[1], lt),
        glow ? baseR * 1.9 : baseR,
        _lerp(_coral, _mint, gt, glow ? 110 : 255),
      );
    }
  }

  // Coral danger node (lower-left).
  disc(
    0.26,
    0.74,
    (glow ? 0.11 : 0.075) * box,
    img.ColorRgba8(_coral[0], _coral[1], _coral[2], glow ? 130 : 255),
  );

  // Mint relief bloom (upper-right).
  if (glow) {
    disc(
      0.74,
      0.26,
      0.20 * box,
      img.ColorRgba8(_mint[0], _mint[1], _mint[2], 140),
    );
  }
  disc(
    0.74,
    0.26,
    (glow ? 0.12 : 0.085) * box,
    img.ColorRgba8(_mint[0], _mint[1], _mint[2], glow ? 150 : 255),
  );
  if (!glow) disc(0.74, 0.26, 0.045 * box, img.ColorRgba8(224, 255, 246, 255));
}

img.Image _compose(int w, int h, double ox, double oy, double box, bool field) {
  final sw = w * _ss, sh = h * _ss;
  final canvas = img.Image(width: sw, height: sh, numChannels: 4);
  if (field) {
    img.fill(
      canvas,
      color: img.ColorRgba8(_field[0], _field[1], _field[2], 255),
    );
  }
  final glow = img.Image(width: sw, height: sh, numChannels: 4);
  _drawMark(glow, ox * _ss, oy * _ss, box * _ss, true);
  final blurred = img.gaussianBlur(glow, radius: (sh * 0.045).round());
  img.compositeImage(canvas, blurred);
  _drawMark(canvas, ox * _ss, oy * _ss, box * _ss, false);
  return img.copyResize(
    canvas,
    width: w,
    height: h,
    interpolation: img.Interpolation.cubic,
  );
}

img.Image _square(int size, {required bool field, required double inset}) {
  final box = size * (1 - 2 * inset);
  return _compose(size, size, size * inset, size * inset, box, field);
}

img.Image _featureGraphic() {
  const w = 1024, h = 500;
  final box = h * 0.78;
  return _compose(w, h, w * 0.07, h * 0.11, box, true);
}

void _write(String path, img.Image image) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $path');
}

void main() {
  // App icon master (legacy/round) — dark field, mark ~76%.
  _write(
    'assets/app_icon/app_icon.png',
    _square(1024, field: true, inset: 0.12),
  );
  // Adaptive foreground — transparent, mark inside the ~56% central safe zone.
  _write(
    'assets/app_icon/app_icon_foreground.png',
    _square(1024, field: false, inset: 0.22),
  );
  // Adaptive background — solid deep field.
  final bg = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(bg, color: img.ColorRgba8(_field[0], _field[1], _field[2], 255));
  _write('assets/app_icon/app_icon_background.png', bg);
  // Play Store listing icon 512².
  _write(
    'assets/store/play-icon-512.png',
    _square(512, field: true, inset: 0.12),
  );
  // Feature graphic 1024×500 — text-free v1 (wordmark overlay added in a design tool).
  _write('assets/store/feature-graphic-1024x500.png', _featureGraphic());
  stdout.writeln('done');
}
