class BadgeModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? earnedAt;

  BadgeModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconUrl,
    this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      earnedAt: json['earned_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'earned_at': earnedAt,
    };
  }
}
