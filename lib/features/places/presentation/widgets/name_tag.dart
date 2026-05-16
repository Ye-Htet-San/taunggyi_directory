import 'package:flutter/material.dart';

class NameTag extends StatelessWidget {
  final String name;
  final Color color;
  const NameTag({super.key, required this.name,required this.color });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _NameTagClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: color,
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _NameTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double triangleWidth = 16; // width of the triangle side
    Path path = Path();
    path.moveTo(0, 0); // top-left
    path.lineTo(size.width - triangleWidth, 0); // top-right before triangle
    path.lineTo(size.width, size.height / 2); // triangle tip
    path.lineTo(size.width - triangleWidth, size.height); // bottom-right before triangle
    path.lineTo(0, size.height); // bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
