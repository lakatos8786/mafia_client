import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum ErrorType { connection, room, game, general }

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = ErrorType.general,
    this.onRetry,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    ErrorType type = ErrorType.general,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        type: type,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Semantics(
        label: '오류: $title. $message',
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getErrorColor().withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getErrorColor().withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getErrorColor().withValues(alpha: 0.15),
                ),
                child: Icon(_getErrorIcon(), size: 32, color: _getErrorColor()),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.gowunDodum(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    _buildButton(
                      label: '다시 시도',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry!();
                      },
                      isPrimary: true,
                    ),
                    const SizedBox(width: 12),
                  ],
                  _buildButton(
                    label: onRetry != null ? '취소' : '확인',
                    onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                    isPrimary: onRetry == null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? _getErrorColor()
            : Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isPrimary ? 4 : 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.gowunDodum(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getErrorColor() {
    switch (type) {
      case ErrorType.connection:
        return AppColors.policeBlue;
      case ErrorType.room:
        return AppColors.accentYellow;
      case ErrorType.game:
        return AppColors.mafiaRed;
      case ErrorType.general:
        return AppColors.deadRed;
    }
  }

  IconData _getErrorIcon() {
    switch (type) {
      case ErrorType.connection:
        return Icons.wifi_off;
      case ErrorType.room:
        return Icons.meeting_room;
      case ErrorType.game:
        return Icons.error_outline;
      case ErrorType.general:
        return Icons.warning_amber;
    }
  }
}
