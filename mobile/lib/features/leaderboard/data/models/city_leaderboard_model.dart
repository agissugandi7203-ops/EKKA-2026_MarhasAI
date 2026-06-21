class CityLeaderboardModel {
  final String cityOrDistrict;
  final String province;
  final int totalXp;
  final int totalReports;
  final int rank;

  CityLeaderboardModel({
    required this.cityOrDistrict,
    required this.province,
    required this.totalXp,
    required this.totalReports,
    required this.rank,
  });

  factory CityLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return CityLeaderboardModel(
      cityOrDistrict: json['city_or_district'] as String,
      province: json['province'] as String,
      totalXp: json['total_xp'] as int? ?? 0,
      totalReports: json['total_reports'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }
}
