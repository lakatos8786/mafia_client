import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/noir_design.dart';

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    int durationSeconds = 2,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.gowunDodum(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: NoirColors.surface,
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NoirDesign.radiusLarge),
          side: BorderSide(color: NoirColors.border),
        ),
      ),
    );
  }
}
