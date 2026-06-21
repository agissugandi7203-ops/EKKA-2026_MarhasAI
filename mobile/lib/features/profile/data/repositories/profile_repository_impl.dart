import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProfileModel> getMyProfile() async {
    return await _remoteDataSource.getMyProfile();
  }

  @override
  Future<ProfileModel> onboardProfile({
    required String username,
    required String fullName,
    required String province,
    required String cityOrDistrict,
  }) async {
    return await _remoteDataSource.onboardProfile(
      username: username,
      fullName: fullName,
      province: province,
      cityOrDistrict: cityOrDistrict,
    );
  }
}
