import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/action_provider.dart';
import '../widgets/custom_snackbar.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';

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
      _showError(AppStrings.enterNickname);
      return false;
    }
    if (name.length > 10) {
      _showError(AppStrings.nicknameMaxLength);
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
    } catch (e) {
      _showError(AppStrings.errorCreateRoom);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    if (_isLoading) return;
    if (!_validateNickname()) return;

    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isEmpty) {
      _showError(AppStrings.enterRoomCode);
      return;
    }
    if (roomCode.length != 6) {
      _showError(AppStrings.invalidRoomCode);
      return;
    }

    setState(() => _isLoading = true);

    try {
      ref
          .read(actionProvider.notifier)
          .joinRoom(roomCode.toUpperCase(), _nameController.text.trim());
    } catch (e) {
      _showError(AppStrings.errorJoinRoom);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                color: AppColors.mafiaRed.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mafiaRed.withValues(alpha: 0.5),
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
                color: AppColors.loginButtonSecondary.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.loginButtonSecondary.withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main UI
          Container(
            color: Colors.transparent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.titleMafia,
                                  style: GoogleFonts.gowunDodum(
                                    fontSize:
                                        (constraints.maxHeight < 480 &&
                                                MediaQuery.of(
                                                      context,
                                                    ).orientation ==
                                                    Orientation.landscape) ||
                                            constraints.maxHeight < 600
                                        ? 40
                                        : 60,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mafiaRed,
                                    letterSpacing: 4.0,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.mafiaRed.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppStrings.titleOnline,
                                  style: GoogleFonts.gowunDodum(
                                    fontSize:
                                        (constraints.maxHeight < 480 &&
                                                MediaQuery.of(
                                                      context,
                                                    ).orientation ==
                                                    Orientation.landscape) ||
                                            constraints.maxHeight < 600
                                        ? 25
                                        : 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 8.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height:
                                (constraints.maxHeight < 480 &&
                                        MediaQuery.of(context).orientation ==
                                            Orientation.landscape) ||
                                    constraints.maxHeight < 600
                                ? 20
                                : 50,
                          ),

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
                                  padding: EdgeInsets.all(
                                    constraints.maxHeight < 480 &&
                                                MediaQuery.of(
                                                      context,
                                                    ).orientation ==
                                                    Orientation.landscape ||
                                            constraints.maxHeight < 600
                                        ? 20
                                        : 30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
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
                                        label: AppStrings.labelNickname,
                                        icon: Icons.person_outline,
                                        maxLength: 10,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9 ]'),
                                          ),
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        onChanged: (value) {
                                          if (value.length > 10) {
                                            _nameController.value =
                                                TextEditingValue(
                                                  text: value.substring(0, 10),
                                                  selection:
                                                      TextSelection.collapsed(
                                                        offset: 10,
                                                      ),
                                                );
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height:
                                            (constraints.maxHeight < 480 &&
                                                    MediaQuery.of(
                                                          context,
                                                        ).orientation ==
                                                        Orientation
                                                            .landscape) ||
                                                constraints.maxHeight < 600
                                            ? 10
                                            : 20,
                                      ),
                                      _buildTextField(
                                        controller: _roomCodeController,
                                        label: AppStrings.labelRoomCode,
                                        icon: Icons.vpn_key_outlined,
                                        isNumber: true,
                                        maxLength: 6,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            (constraints.maxHeight < 480 &&
                                                    MediaQuery.of(
                                                          context,
                                                        ).orientation ==
                                                        Orientation
                                                            .landscape) ||
                                                constraints.maxHeight < 600
                                            ? 20
                                            : 30,
                                      ),
                                      _buildButton(
                                        text: AppStrings.btnCreateRoom,
                                        onPressed: _isLoading
                                            ? null
                                            : _createRoom,
                                        color: AppColors.mafiaRed,
                                        isLoading: _isLoading,
                                      ),
                                      SizedBox(
                                        height:
                                            (constraints.maxHeight < 480 &&
                                                    MediaQuery.of(
                                                          context,
                                                        ).orientation ==
                                                        Orientation
                                                            .landscape) ||
                                                constraints.maxHeight < 600
                                            ? 10
                                            : 15,
                                      ),
                                      _buildButton(
                                        text: AppStrings.btnJoinRoom,
                                        onPressed: _isLoading
                                            ? null
                                            : _joinRoom,
                                        color: AppColors.loginButtonSecondary,
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
                );
              },
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
    MaxLengthEnforcement? maxLengthEnforcement,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
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
          borderSide: const BorderSide(color: AppColors.mafiaRed),
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
