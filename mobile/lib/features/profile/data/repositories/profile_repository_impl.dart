import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProfileModel> getMyProfile() async {
    try {
      return await _remoteDataSource.getMyProfile();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<ProfileModel> onboardProfile({
    required String username,
    required String fullName,
    required String province,
    required String cityOrDistrict,
  }) async {
    try {
      return await _remoteDataSource.onboardProfile(
        username: username,
        fullName: fullName,
        province: province,
        cityOrDistrict: cityOrDistrict,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
