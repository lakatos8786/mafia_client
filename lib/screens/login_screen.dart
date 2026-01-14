import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/action_provider.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  bool _validateNickname() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('닉네임을 입력해주세요');
      return false;
    }
    if (name.isEmpty) {
      _showError('닉네임은 최소 1자 이상이어야 합니다');
      return false;
    }
    if (name.length > 10) {
      _showError('닉네임은 최대 10자까지 가능합니다');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    CustomSnackBar.show(context, message);
  }

  Future<void> _createRoom() async {
    if (_isLoading) return;
    if (!_validateNickname()) return;

    setState(() => _isLoading = true);

    try {
      ref.read(actionProvider.notifier).createRoom(_nameController.text.trim());
      // Navigation is handled by listening to socket events or game state changes elsewhere?
      // Original code did not await. It just emitted.
      // We expect the app to navigate when `GamePhase` or joined room state changes.
      // So we just set loading.
      // Ideally we should reset loading if it fails, but socket emit is fire-and-forget mostly.
      // We can listen to errors on ConnectionProvider or something.
      // For now, keep as is (UI relies on Stream/Listener updates to navigate away).
      // But we should probably timeout _isLoading?
      // Original code kept _isLoading = true until navigation replaced the screen.
    } catch (e) {
      _showError('방 생성 중 오류가 발생했습니다');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    if (_isLoading) return;
    if (!_validateNickname()) return;

    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isEmpty) {
      _showError('방 코드를 입력해주세요');
      return;
    }
    if (roomCode.length != 6) {
      _showError('방 코드는 6자리 숫자입니다');
      return;
    }

    setState(() => _isLoading = true);

    try {
      ref
          .read(actionProvider.notifier)
          .joinRoom(roomCode.toUpperCase(), _nameController.text.trim());
    } catch (e) {
      _showError('방 참여 중 오류가 발생했습니다');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep Dark Blue
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE94560).withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE94560).withValues(alpha: 0.5),
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
                color: const Color(0xFF0F3460).withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3460).withValues(alpha: 0.5),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
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
                                '마피아',
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE94560),
                                  letterSpacing: 4.0,
                                  shadows: [
                                    Shadow(
                                      color: const Color(
                                        0xFFE94560,
                                      ).withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '온라인',
                                style: GoogleFonts.gowunDodum(
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
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _nameController,
                                      label: '닉네임 (1-10자)',
                                      icon: Icons.person_outline,
                                      maxLength: 10,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9 ]'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      controller: _roomCodeController,
                                      label: '방 코드 (6자리)',
                                      icon: Icons.vpn_key_outlined,
                                      isNumber: true,
                                      maxLength: 6,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    _buildButton(
                                      text: '방 만들기',
                                      onPressed: _isLoading
                                          ? null
                                          : _createRoom,
                                      color: const Color(0xFFE94560),
                                      isLoading: _isLoading,
                                    ),
                                    const SizedBox(height: 15),
                                    _buildButton(
                                      text: '방 참여하기',
                                      onPressed: _isLoading ? null : _joinRoom,
                                      color: const Color(0xFF0F3460),
                                      isOutlined: true,
                                      isLoading: _isLoading,
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
    required VoidCallback? onPressed,
    required Color color,
    bool isOutlined = false,
    bool isLoading = false,
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
          shadowColor: isOutlined
              ? Colors.transparent
              : color.withValues(alpha: 0.5),
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: isOutlined
              ? Colors.transparent
              : color.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
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
