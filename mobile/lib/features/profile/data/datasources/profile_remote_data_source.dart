import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  
  Future<ProfileModel> onboardProfile({
    required String username,
    required String fullName,
    required String province,
    required String cityOrDistrict,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ProfileModel> getMyProfile() async {
    final response = await _dioClient.dio.get('/profiles/me');
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProfileModel> onboardProfile({
    required String username,
    required String fullName,
    required String province,
    required String cityOrDistrict,
  }) async {
    final response = await _dioClient.dio.post(
      '/profiles/onboard',
      data: {
        'username': username,
        'full_name': fullName,
        'province': province,
        'city_or_district': cityOrDistrict,
      },
    );
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
