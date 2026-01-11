import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  void _createRoom() {
    if (_nameController.text.isNotEmpty) {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).createRoom(_nameController.text);
    }
  }

  void _joinRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomCodeController.text.isNotEmpty) {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).joinRoom(_nameController.text, _roomCodeController.text.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep Dark Blue
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Elements (Abstract Neon Globs)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE94560).withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE94560).withOpacity(0.5),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F3460).withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3460).withOpacity(0.5),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        children: [
                          Text(
                            'MAFIA',
                            style: GoogleFonts.blackHanSans(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE94560),
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: const Color(
                                    0xFFE94560,
                                  ).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.blackHanSans(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 8.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Glassmorphism Container
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 800),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 350,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'NICKNAME',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _roomCodeController,
                                  label: 'ROOM CODE (JOIN)',
                                  icon: Icons.vpn_key_outlined,
                                  isNumber: true,
                                ),
                                const SizedBox(height: 30),
                                _buildButton(
                                  text: 'CREATE ROOM',
                                  onPressed: _createRoom,
                                  color: const Color(0xFFE94560),
                                ),
                                const SizedBox(height: 15),
                                _buildButton(
                                  text: 'JOIN ROOM',
                                  onPressed: _joinRoom,
                                  color: const Color(0xFF0F3460),
                                  isOutlined: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE94560)),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: Colors.white,
          elevation: isOutlined ? 0 : 5,
          shadowColor: isOutlined ? Colors.transparent : color.withOpacity(0.5),
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
