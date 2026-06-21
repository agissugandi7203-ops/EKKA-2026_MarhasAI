class UserLeaderboardModel {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int reportCount;
  final int rank;

  UserLeaderboardModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.xp,
    required this.level,
    required this.reportCount,
    required this.rank,
  });

  factory UserLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return UserLeaderboardModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'warga_genesis',
      fullName: json['full_name'] as String? ?? 'Warga Anonim',
      avatarUrl: json['avatar_url'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      reportCount: json['report_count'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }
}
