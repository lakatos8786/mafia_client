import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonToast {
  static void show(
    BuildContext context,
    String message, {
    int durationSeconds = 2,
  }) {
    // For feedback in Modals (like BottomSheet), standard SnackBar can be hidden behind.
    // Using Overlay ensures it appears on top of everything.
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NeonToast(
        message: message,
        duration: Duration(seconds: durationSeconds),
        onRemove: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _NeonToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onRemove;

  const _NeonToast({
    required this.message,
    required this.duration,
    required this.onRemove,
  });

  @override
  State<_NeonToast> createState() => _NeonToastState();
}

class _NeonToastState extends State<_NeonToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.5), // Slide up from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto-remove logic
    _startExitLogic();
  }

  void _startExitLogic() async {
    await Future.delayed(widget.duration - const Duration(milliseconds: 300));
    if (mounted) {
      await _controller.reverse();
      widget.onRemove();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 50,
          ), // Positioned above bottom bar/sheet
          child: SlideTransition(
            position: _offset,
            child: FadeTransition(
              opacity: _opacity,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FBFF).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FBFF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF00FBFF),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.message,
                        style: GoogleFonts.ibmPlexSansKr(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
