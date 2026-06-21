import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getMyProfile();
  
  Future<ProfileModel> onboardProfile({
    required String username,
    required String fullName,
    required String province,
    required String cityOrDistrict,
  });
}
