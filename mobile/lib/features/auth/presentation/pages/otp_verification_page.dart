import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/ios_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman verifikasi kode OTP dari email — Redesain.
///
/// Menyediakan:
/// - Input OTP 6-digit PIN
/// - Pinned bottom buttons: "Next" & "Back"
class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = AppConstants.otpResendSeconds;
  bool _canResend = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _otpController.addListener(_onOtpLengthChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpLengthChanged);
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onOtpLengthChanged() {
    final bool isComplete = _otpController.text.length == 6;
    if (isComplete != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isComplete);
    }
  }

  void _startResendTimer() {
    _canResend = false;
    _resendSeconds = AppConstants.otpResendSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  void _onSubmit() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
            VerifyOtpRequested(email: widget.email, token: _otpController.text),
          );
    }
  }

  void _onResend() {
    context.read<AuthBloc>().add(ForgotPasswordRequested(widget.email));
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          context.goNamed(Routes.resetPasswordName);
        } else if (state is AuthFailure) {
          context.showErrorSnackBar(state.errorMessage);
          _otpController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.spacing32),

                      // Header
                      AuthHeader(
                        title: 'Verification Code',
                        subtitle: 'We have sent the OTP code to your email for the verification process.',
                        icon: Icons.mark_email_read_outlined,
                      ),
                      const SizedBox(height: AppConstants.spacing8),

                      // Email Target
                      Text(
                        widget.email,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: const Color(0xFF007AFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing40),

                      // PIN Input (Spacious & Rounded boxes)
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PinCodeTextField(
                            appContext: context,
                            length: 6,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            enabled: state is! AuthLoading,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(16),
                              fieldHeight: 56,
                              fieldWidth: 46,
                              activeFillColor: Colors.white,
                              inactiveFillColor: AppColors.navy50,
                              selectedFillColor: Colors.white,
                              activeColor: const Color(0xFF007AFF),
                              inactiveColor: AppColors.divider,
                              selectedColor: const Color(0xFF007AFF),
                              borderWidth: 1.5,
                            ),
                            enableActiveFill: true,
                            textStyle: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            onCompleted: (_) => _onSubmit(),
                            onChanged: (_) {},
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spacing24),

                      // Resend Code Link
                      if (_canResend)
                        TextButton(
                          onPressed: _onResend,
                          child: Text(
                            'Kirim Ulang Kode',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: const Color(0xFF007AFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Kirim ulang kode dalam ${_resendSeconds}s',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final bool isLoading = state is AuthLoading;
                  return IosBottomButtons(
                    nextText: 'Next',
                    onNextPressed: _onSubmit,
                    isNextLoading: isLoading,
                    isNextEnabled: _isButtonEnabled,
                    backText: 'Back',
                    onBackPressed: () => context.pop(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
