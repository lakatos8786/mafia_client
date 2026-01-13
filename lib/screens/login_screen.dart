import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _roomCodeFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    _nameFocusNode.dispose();
    _roomCodeFocusNode.dispose();
    super.dispose();
  }

  bool _validateNickname() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('닉네임을 입력해주세요');
      return false;
    }
    if (name.length < 1) {
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

  void _createRoom() {
    if (_isLoading) return;
    if (!_validateNickname()) return;

    setState(() => _isLoading = true);

    try {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).createRoom(_nameController.text.trim());
    } catch (e) {
      _showError('방 생성 중 오류가 발생했습니다');
      setState(() => _isLoading = false);
    }
  }

  void _joinRoom() {
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
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).joinRoom(roomCode.toUpperCase(), _nameController.text.trim());
    } catch (e) {
      _showError('방 참여 중 오류가 발생했습니다');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      // Use Flutter's built-in keyboard handling
      resizeToAvoidBottomInset: true,
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

          // Main content with proper keyboard handling
          GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Colors.transparent,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
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
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        width: 350,
                                        padding: const EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildTextField(
                                              controller: _nameController,
                                              focusNode: _nameFocusNode,
                                              label: '닉네임 (1-10자)',
                                              icon: Icons.person_outline,
                                              maxLength: 10,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                    r'[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9 ]',
                                                  ),
                                                ),
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              onSubmitted: (_) {
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(
                                                  _roomCodeFocusNode,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            _buildTextField(
                                              controller: _roomCodeController,
                                              focusNode: _roomCodeFocusNode,
                                              label: '방 코드 (참여 전용)',
                                              icon: Icons.vpn_key_outlined,
                                              isNumber: true,
                                              maxLength: 6,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textInputAction:
                                                  TextInputAction.done,
                                              onSubmitted: (_) {
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                              },
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
                                              onPressed: _isLoading
                                                  ? null
                                                  : _joinRoom,
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
                    );
                  },
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
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        counterText: '', // Hide the counter
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
