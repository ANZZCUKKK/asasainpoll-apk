import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool active;
  final ValueChanged<bool> onChanged;

  const FeatureToggle({
    super.key,
    required this.label, required this.subtitle,
    required this.icon, required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00E5FF).withOpacity(0.08)
              : const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? const Color(0xFF00E5FF) : Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: active ? const Color(0xFF00E5FF) : Colors.white30,
                size: 20),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.jetBrainsMono(
                fontSize: 10, fontWeight: FontWeight.bold,
                color: active ? const Color(0xFF00E5FF) : Colors.white60,
                letterSpacing: 1)),
            Text(subtitle, style: GoogleFonts.jetBrainsMono(
                fontSize: 9, color: Colors.white30)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF00E5FF).withOpacity(0.15)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(active ? 'ON' : 'OFF',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, fontWeight: FontWeight.bold,
                      color: active ? const Color(0xFF00E5FF) : Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
