import '../../data/models/user_leaderboard_model.dart';
import '../../data/models/city_leaderboard_model.dart';

abstract class LeaderboardRepository {
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100});
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100});
}
