import 'dart:ui';

import 'models.dart';

/// Geometry helpers for hazard collision.
///
/// Spikes are *drawn* as triangles but were historically tested as their full
/// bounding rectangle, so the player could die in the visibly empty corners
/// beside the tip. These pure functions test the actual triangle, which keeps
/// deaths looking fair — important in a troll game where the player must trust
/// that unfair-looking hits are designed, not sloppy.

/// The three screen-space corners of a spike's drawn triangle, matching the
/// path built by the painter.
List<Offset> spikeTriangle(Spike spike) {
  final r = spike.rect;
  if (spike.direction == SpikeDirection.up) {
    return [
      Offset(r.left, r.bottom),
      Offset(r.center.dx, r.top),
      Offset(r.right, r.bottom),
    ];
  }
  return [
    Offset(r.left, r.top),
    Offset(r.center.dx, r.bottom),
    Offset(r.right, r.top),
  ];
}

/// Whether a spike's triangle overlaps [playerRect]. Uses the Separating Axis
/// Theorem over the rectangle's two axes plus the triangle's three edge
/// normals; both shapes are convex, so a gap on any axis means no collision.
bool spikeHitsPlayer(Spike spike, Rect playerRect) {
  return _triangleIntersectsRect(spikeTriangle(spike), playerRect);
}

bool _triangleIntersectsRect(List<Offset> triangle, Rect rect) {
  final rectCorners = [
    rect.topLeft,
    rect.topRight,
    rect.bottomRight,
    rect.bottomLeft,
  ];

  final axes = <Offset>[
    const Offset(1, 0),
    const Offset(0, 1),
  ];
  for (var i = 0; i < triangle.length; i++) {
    final edge = triangle[(i + 1) % triangle.length] - triangle[i];
    axes.add(Offset(-edge.dy, edge.dx));
  }

  for (final axis in axes) {
    final tri = _project(triangle, axis);
    final box = _project(rectCorners, axis);
    if (tri.max < box.min || box.max < tri.min) {
      return false;
    }
  }
  return true;
}

_Range _project(List<Offset> points, Offset axis) {
  var min = double.infinity;
  var max = double.negativeInfinity;
  for (final p in points) {
    final d = p.dx * axis.dx + p.dy * axis.dy;
    if (d < min) min = d;
    if (d > max) max = d;
  }
  return _Range(min, max);
}

class _Range {
  const _Range(this.min, this.max);
  final double min;
  final double max;
}
