import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CherryBlossomBackground extends StatefulWidget {
  const CherryBlossomBackground({super.key});

  @override
  State<CherryBlossomBackground> createState() => _CherryBlossomBackgroundState();
}

class _CherryBlossomBackgroundState extends State<CherryBlossomBackground> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 10))
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fill the entire screen
    return Positioned.fill(
      child: IgnorePointer(
        child: ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.02,
          numberOfParticles: 8,
          maxBlastForce: 20,
          minBlastForce: 5,
          gravity: 0.05,
          colors: [
            Colors.pink.shade300,
            Colors.pink.shade200,
          ],
          createParticlePath: drawPetal,
        ),
      ),
    );
  }

  // Simple petal shape
  Path drawPetal(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(size.width, size.height / 3, size.width / 2, size.height)
      ..quadraticBezierTo(0, size.height / 3, size.width / 2, 0);
  }
}
