import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';
import '../models/user_leaderboard_model.dart';
import '../models/city_leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _remoteDataSource;

  LeaderboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<UserLeaderboardModel>> getGlobalLeaderboard({int limit = 100}) async {
    try {
      return await _remoteDataSource.getGlobalLeaderboard(limit: limit);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<List<CityLeaderboardModel>> getCityLeaderboard({int limit = 100}) async {
    try {
      return await _remoteDataSource.getCityLeaderboard(limit: limit);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
