import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/genesis_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman reset password — input password baru setelah OTP terverifikasi.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ResetPasswordRequested(_passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah! Silakan masuk.'),
              backgroundColor: AppColors.emerald,
            ),
          );
          context.goNamed(Routes.loginName);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthHeader(
                      title: 'Buat Password Baru',
                      subtitle:
                          'Password baru harus berbeda dari password sebelumnya',
                      icon: Icons.vpn_key_rounded,
                    ),
                    const SizedBox(height: AppConstants.spacing40),

                    GenesisTextField(
                      label: 'Password Baru',
                      hint: 'Minimal 8 karakter, 1 huruf besar, 1 angka',
                      controller: _passwordController,
                      validator: Validators.password,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    GenesisTextField(
                      label: 'Konfirmasi Password Baru',
                      hint: 'Ketik ulang password baru',
                      controller: _confirmController,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _onSubmit,
                    ),
                    const SizedBox(height: AppConstants.spacing32),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return GenesisButton(
                          text: 'Simpan Password Baru',
                          onPressed: _onSubmit,
                          isLoading: state is AuthLoading,
                          prefixIcon: Icons.check_circle_outline_rounded,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
