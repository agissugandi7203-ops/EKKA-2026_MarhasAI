import 'badge_model.dart';

class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? province;
  final String? cityOrDistrict;
  final int xp;
  final int level;
  final int reportCount;
  final int currentStreak;
  final String? lastReportDate;
  final String role;
  final String createdAt;
  final String updatedAt;
  final List<BadgeModel> badges;

  ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.province,
    this.cityOrDistrict,
    required this.xp,
    required this.level,
    required this.reportCount,
    required this.currentStreak,
    this.lastReportDate,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.badges,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    var badgeList = json['badges'] as List? ?? [];
    List<BadgeModel> parsedBadges = badgeList.map((i) => BadgeModel.fromJson(i as Map<String, dynamic>)).toList();

    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      province: json['province'] as String?,
      cityOrDistrict: json['city_or_district'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      reportCount: json['report_count'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      lastReportDate: json['last_report_date'] as String?,
      role: json['role'] as String? ?? 'citizen',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      badges: parsedBadges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'province': province,
      'city_or_district': cityOrDistrict,
      'xp': xp,
      'level': level,
      'report_count': reportCount,
      'current_streak': currentStreak,
      'last_report_date': lastReportDate,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'badges': badges.map((b) => b.toJson()).toList(),
    };
  }
}
