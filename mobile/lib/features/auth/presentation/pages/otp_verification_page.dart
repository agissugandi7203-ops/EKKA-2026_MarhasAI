import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman verifikasi kode OTP dari email.
///
/// Menampilkan 6-digit PIN input field dengan countdown timer
/// untuk pengiriman ulang kode.
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

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
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

  void _onOtpComplete(String otp) {
    context.read<AuthBloc>().add(
          VerifyOtpRequested(email: widget.email, token: otp),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
          _otpController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthHeader(
                    title: 'Verifikasi Email',
                    subtitle: 'Masukkan 6 digit kode yang dikirim ke',
                    icon: Icons.mark_email_read_outlined,
                  ),
                  const SizedBox(height: AppConstants.spacing8),

                  // Email target
                  Text(
                    widget.email,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.navy700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing40),

                  // ── OTP PIN Input ──
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
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                          fieldHeight: 56,
                          fieldWidth: 48,
                          activeFillColor: AppColors.cardBackground,
                          inactiveFillColor: AppColors.surface,
                          selectedFillColor: AppColors.navy50,
                          activeColor: AppColors.navy600,
                          inactiveColor: AppColors.divider,
                          selectedColor: AppColors.navy700,
                        ),
                        enableActiveFill: true,
                        textStyle: AppTextStyles.headlineMedium,
                        onCompleted: _onOtpComplete,
                        onChanged: (_) {},
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // ── Loading indicator ──
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Padding(
                          padding:
                              EdgeInsets.only(bottom: AppConstants.spacing24),
                          child: CircularProgressIndicator(
                            color: AppColors.navy700,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // ── Resend Timer ──
                  if (_canResend)
                    TextButton(
                      onPressed: _onResend,
                      child: Text(
                        'Kirim Ulang Kode',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.navy600,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Kirim ulang kode dalam ${_resendSeconds}s',
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
