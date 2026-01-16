import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/action_provider.dart';
import '../providers/game_state_provider.dart';
import '../widgets/custom_snackbar.dart';
import '../theme/app_strings.dart';
import '../theme/noir_design.dart';
import '../utils/responsive_utils.dart';
import '../widgets/common/noir_button.dart';
import '../widgets/common/noir_card.dart';

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
    // Listen for server errors to reset loading state
    ref.listen(gameStateProvider.select((s) => s.lastErrorTime), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        final errorMsg = ref.read(gameStateProvider).errorMessage;
        if (errorMsg != null) {
          setState(() => _isLoading = false);
          _showError(errorMsg);
        }
      }
    });

    return Scaffold(
      backgroundColor: NoirColors.backgroundBase,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      48,
                                    ),
                                    fontWeight: FontWeight.w900,
                                    color: NoirColors.textPrimary,
                                    letterSpacing: ResponsiveUtils.spacing(
                                      context,
                                      4,
                                    ),
                                    shadows: [
                                      Shadow(
                                        color: NoirColors.crimson.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppStrings.titleOnline,
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      32,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: NoirColors.textSecondary,
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
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: ResponsiveUtils.iconSize(
                                  context,
                                  340,
                                ),
                              ),
                              child: NoirCard(
                                variant: NoirCardVariant.base,
                                elevation: NoirCardElevation.standard,
                                padding: ResponsiveUtils.padding(context, 24),
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
                                          _nameController
                                              .value = TextEditingValue(
                                            text: value.substring(0, 10),
                                            selection: TextSelection.collapsed(
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
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                    SizedBox(
                                      height: ResponsiveUtils.spacing(
                                        context,
                                        24,
                                      ),
                                    ),
                                    NoirButton(
                                      text: AppStrings.btnCreateRoom,
                                      onPressed: () => _createRoom(),
                                      style: NoirButtonStyle.primary,
                                      isLoading: _isLoading,
                                      fullWidth: true,
                                    ),
                                    SizedBox(
                                      height: ResponsiveUtils.spacing(
                                        context,
                                        12,
                                      ),
                                    ),
                                    NoirButton(
                                      text: AppStrings.btnJoinRoom,
                                      onPressed: () => _joinRoom(),
                                      style: NoirButtonStyle.secondary,
                                      isLoading: _isLoading,
                                      fullWidth: true,
                                    ),
                                  ],
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
      style: const TextStyle(
        color: NoirColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(
          color: NoirColors.textTertiary,
          fontSize: ResponsiveUtils.fontSize(context, 13),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(
          icon,
          color: NoirColors.textSecondary,
          size: ResponsiveUtils.iconSize(context, 20),
        ),
        filled: true,
        fillColor: NoirColors.surfaceDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoirDesign.radiusMedium),
          borderSide: BorderSide(color: NoirColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoirDesign.radiusMedium),
          borderSide: BorderSide(color: NoirColors.crimson, width: 1.5),
        ),
      ),
    );
  }
}
