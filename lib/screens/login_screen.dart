import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/action_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/custom_snackbar.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';
import '../models/game_enums.dart';
import '../utils/responsive_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;
  String _loadingStatus = '입장 중...';

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

  String _mapErrorMessage(dynamic error) {
    String? code;
    String? message;

    if (error is Map) {
      code = error['code']?.toString();
      message = error['message']?.toString();
    } else {
      message = error.toString();
    }

    // 1. Map by standardized error codes
    if (code != null) {
      switch (code) {
        case ErrorCode.roomNotFound:
          return "입력하신 방 번호가 존재하지 않습니다.";
        case ErrorCode.nicknameTaken:
          return "이미 사용 중인 닉네임입니다.";
        case ErrorCode.gameStarted:
          return "이미 게임이 시작된 방입니다.";
        case ErrorCode.roomFull:
          return "방의 인원이 가득 차서 입장할 수 없습니다.";
        case ErrorCode.notHost:
          return "방장 권한이 필요한 기능입니다.";
        case ErrorCode.kicked:
          return "지정된 방에서 강퇴되었습니다.";
        case ErrorCode.invalidParams:
          return "잘못된 요청 정보입니다.";
      }
    }

    // 2. Fallback to text-based mapping for backward compatibility
    final lowerError = message?.toLowerCase() ?? '';
    if (lowerError.contains('room_not_found') ||
        lowerError.contains('not found') ||
        lowerError.contains('존재하지 않는 방')) {
      return "입력하신 방 번호가 존재하지 않습니다.";
    }
    if (lowerError.contains('room_full') ||
        lowerError.contains('full') ||
        lowerError.contains('가득 찼습니다')) {
      return "방의 인원이 가득 차서 입장할 수 없습니다.";
    }
    if (lowerError.contains('already_started') ||
        lowerError.contains('started') ||
        lowerError.contains('이미 게임이 시작')) {
      return "이미 게임이 시작된 방입니다.";
    }
    if (lowerError.contains('invalid_nickname') ||
        lowerError.contains('nickname') ||
        lowerError.contains('사용 중인 닉네임')) {
      return "사용할 수 없는 닉네임입니다.";
    }
    if (lowerError.contains('kicked') || lowerError.contains('강퇴')) {
      return "지정된 방에서 강퇴되었습니다.";
    }

    return message ?? "알 수 없는 오류가 발생했습니다.";
  }

  Future<void> _createRoom() async {
    if (_isLoading) return;
    if (!ref.read(connectionProvider).isConnected) {
      _showError("현재 서버와 연결되어 있지 않습니다. 잠시 후 다시 시도해 주세요.");
      return;
    }
    if (!_validateNickname()) return;

    setState(() {
      _isLoading = true;
      _loadingStatus = '방 생성 중...';
    });

    // Staged feedback for creating room
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading && mounted) {
        setState(() => _loadingStatus = '서버 응답 대기 중...');
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && mounted) {
        setState(() => _isLoading = false);
        final isConnected = ref.read(connectionProvider).isConnected;
        _showError(
          isConnected
              ? '서버 응답이 지연되고 있습니다. 다시 시도해 주세요.'
              : '서버와 연결이 끊어졌습니다. 네트워크 상태를 확인해 주세요.',
        );
      }
    });

    try {
      ref.read(actionProvider.notifier).createRoom(_nameController.text.trim());
    } catch (e) {
      _showError(AppStrings.errorCreateRoom);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    if (_isLoading) return;
    if (!ref.read(connectionProvider).isConnected) {
      _showError("현재 서버와 연결되어 있지 않습니다. 잠시 후 다시 시도해 주세요.");
      return;
    }
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

    setState(() {
      _isLoading = true;
      _loadingStatus = '입장 중...';
    });

    // Staged feedback for joining room
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading && mounted) {
        setState(() => _loadingStatus = '서버 응답 대기 중...');
      }
    });

    // 5-second timeout for joining room
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && mounted) {
        setState(() => _isLoading = false);
        final isConnected = ref.read(connectionProvider).isConnected;
        _showError(
          isConnected
              ? '서버 응답이 지연되고 있습니다. 다시 시도해 주세요.'
              : '서버와 연결이 끊어졌습니다. 네트워크 상태를 확인해 주세요.',
        );
      }
    });

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
    // Listen for server errors to reset loading state
    ref.listen(gameStateProvider.select((s) => s.lastErrorTime), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        final errorMsg = ref.read(gameStateProvider).errorMessage;
        if (errorMsg != null) {
          setState(() => _isLoading = false);
          _showError(_mapErrorMessage(errorMsg));
        }
      }
    });

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
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 28),
                        vertical: ResponsiveUtils.padding(context, 32),
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
                                  style: GoogleFonts.ibmPlexSansKr(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      48,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mafiaRed,
                                    letterSpacing: ResponsiveUtils.spacing(
                                      context,
                                      4,
                                    ),
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
                                  style: GoogleFonts.ibmPlexSansKr(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      32,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: ResponsiveUtils.spacing(
                                      context,
                                      6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.spacing(context, 40),
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
                                  constraints: BoxConstraints(
                                    maxWidth: 400,
                                    minWidth: ResponsiveUtils.iconSize(
                                      context,
                                      280,
                                    ),
                                  ),
                                  width: constraints.maxWidth * 0.9,
                                  padding: EdgeInsets.all(
                                    ResponsiveUtils.padding(context, 24),
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
                                        height: ResponsiveUtils.spacing(
                                          context,
                                          16,
                                        ),
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
                                        height: ResponsiveUtils.spacing(
                                          context,
                                          24,
                                        ),
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
                                        height: ResponsiveUtils.spacing(
                                          context,
                                          12,
                                        ),
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
          fontSize: ResponsiveUtils.fontSize(context, 13),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white54,
          size: ResponsiveUtils.iconSize(context, 20),
        ),
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
      height: ResponsiveUtils.iconSize(context, 46),
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
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _loadingStatus,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                  letterSpacing: ResponsiveUtils.spacing(context, 1.2),
                ),
              ),
      ),
    );
  }
}
