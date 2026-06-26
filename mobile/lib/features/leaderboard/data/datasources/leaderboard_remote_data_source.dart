import '../../../../core/network/dio_client.dart';
import '../models/user_leaderboard_model.dart';
import '../models/city_leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100, String? city, String? province});
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100});
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final DioClient _dioClient;

  LeaderboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100, String? city, String? province}) async {
    final Map<String, dynamic> query = {'limit': limit};
    if (city != null && city.isNotEmpty) query['city'] = city;
    if (province != null && province.isNotEmpty) query['province'] = province;

    final response = await _dioClient.dio.get(
      '/leaderboard/global',
      queryParameters: query,
    );
    final list = response.data as List? ?? [];
    return list.map((item) => UserLeaderboardModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100}) async {
    final response = await _dioClient.dio.get(
      '/leaderboard/city',
      queryParameters: {'limit': limit},
    );
    final list = response.data as List? ?? [];
    return list.map((item) => CityLeaderboardModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
