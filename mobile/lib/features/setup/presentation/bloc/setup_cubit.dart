import 'package:flutter_bloc/flutter_bloc.dart';

import 'setup_state.dart';

/// Cubit untuk mengelola state Setup Wizard post-login.
///
/// Mengumpulkan data dari 4 langkah setup sebelum user masuk ke Home.
/// Menggunakan Cubit (bukan Bloc) karena flow ini lebih sederhana — tidak
/// membutuhkan event stream yang kompleks.
class SetupCubit extends Cubit<SetupState> {
  SetupCubit() : super(const SetupState());

  /// Pindah ke step berikutnya.
  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Kembali ke step sebelumnya.
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Simpan data lokasi dari GPS / manual input.
  void setLocation({
    required String province,
    required String cityOrDistrict,
  }) {
    emit(state.copyWith(
      province: province,
      cityOrDistrict: cityOrDistrict,
      locationPermissionGranted: true,
    ));
  }

  /// Tandai izin notifikasi telah diberikan/ditolak.
  void setNotificationPermission({required bool granted}) {
    emit(state.copyWith(notificationPermissionGranted: granted));
  }

  /// Set status submitting saat mengirim data ke server.
  void setSubmitting(bool isSubmitting) {
    emit(state.copyWith(isSubmitting: isSubmitting));
  }

  /// Set pesan error.
  void setError(String message) {
    emit(state.copyWith(errorMessage: message, isSubmitting: false));
  }

  /// Clear error.
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
