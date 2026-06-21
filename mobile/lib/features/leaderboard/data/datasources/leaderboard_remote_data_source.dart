import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_leaderboard_model.dart';
import '../models/city_leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100});
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100});
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final DioClient _dioClient;

  LeaderboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100}) async {
    try {
      final response = await _dioClient.dio.get(
        '/leaderboard/global',
        queryParameters: {'limit': limit},
      );
      final list = response.data as List? ?? [];
      return list.map((item) => UserLeaderboardModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat leaderboard global: ${e.response?.data['message'] ?? e.message}');
    }
  }

  @override
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100}) async {
    try {
      final response = await _dioClient.dio.get(
        '/leaderboard/city',
        queryParameters: {'limit': limit},
      );
      final list = response.data as List? ?? [];
      return list.map((item) => CityLeaderboardModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat leaderboard kota: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
