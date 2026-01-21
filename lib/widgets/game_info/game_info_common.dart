import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 섹션 공통 위젯
class SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final double scaleFactor;

  const SectionWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// 정보 행 공통 위젯
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double scaleFactor;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.scaleFactor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 14 * scaleFactor,
            color: Colors.white54,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.ibmPlexSansKr(
                fontSize: 14 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}
