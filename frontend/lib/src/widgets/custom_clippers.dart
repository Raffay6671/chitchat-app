import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clips the left half of a circle (180° from 90° to 270°).
class LeftHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.arcTo(
      Rect.fromLTWH(0, 0, size.width, size.height),
      math.pi / 2, // Start at 90° (left center)
      math.pi, // Sweep 180° (half-circle)
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

class TopRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from top-center
    path.moveTo(size.width / 2, 0);

    // Draw arc from 270° (top-center) to 360° (right-center)
    path.arcTo(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3 * math.pi / 2, // Start at 270° (top-center)
      math.pi / 2, // Sweep 90° (top-right quarter-circle)
      false,
    );

    path.lineTo(size.width / 2, size.height / 2); // Connect to center
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from bottom-center
    path.moveTo(size.width / 2, size.height);

    // Draw arc from 90° (bottom-center) to 180° (left-center)
    path.arcTo(
      Rect.fromLTWH(0, 0, size.width, size.height),
      math.pi / 2, // Start at 90° (bottom-center)
      -math.pi / 2, // Sweep -90° (bottom-left quarter-circle)
      false,
    );

    path.lineTo(size.width / 2, size.height / 2); // Connect to center
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
