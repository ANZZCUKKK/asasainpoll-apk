import 'package:flutter/material.dart';

class StatusDot extends StatelessWidget {
  final bool isOnline;
  final Animation<double> pulse;

  const StatusDot({super.key, required this.isOnline, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? const Color(0xFF00E5FF) : Colors.red,
          boxShadow: isOnline ? [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(pulse.value * 0.6),
              blurRadius: 8, spreadRadius: 2,
            )
          ] : [],
        ),
      ),
    );
  }
}
