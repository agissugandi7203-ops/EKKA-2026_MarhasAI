import 'package:equatable/equatable.dart';

/// State untuk Setup Wizard post-login.
///
/// Menyimpan data yang dikumpulkan selama proses setup 4 langkah.
/// Immutable — setiap perubahan menghasilkan instance baru via [copyWith].
class SetupState extends Equatable {
  final int currentStep;
  final int totalSteps;
  final String? province;
  final String? cityOrDistrict;
  final bool locationPermissionGranted;
  final bool notificationPermissionGranted;
  final bool isSubmitting;
  final String? errorMessage;

  const SetupState({
    this.currentStep = 0,
    this.totalSteps = 4,
    this.province,
    this.cityOrDistrict,
    this.locationPermissionGranted = false,
    this.notificationPermissionGranted = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Progress normalized (0.0 — 1.0).
  double get progress => (currentStep + 1) / totalSteps;

  SetupState copyWith({
    int? currentStep,
    String? province,
    String? cityOrDistrict,
    bool? locationPermissionGranted,
    bool? notificationPermissionGranted,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return SetupState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps,
      province: province ?? this.province,
      cityOrDistrict: cityOrDistrict ?? this.cityOrDistrict,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        totalSteps,
        province,
        cityOrDistrict,
        locationPermissionGranted,
        notificationPermissionGranted,
        isSubmitting,
        errorMessage,
      ];
}
