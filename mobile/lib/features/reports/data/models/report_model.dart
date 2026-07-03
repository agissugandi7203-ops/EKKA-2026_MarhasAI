class ReportModel {
  final String id;
  final String reporterId;
  final String imageUrl;
  final String? description;
  final double latitude;
  final double longitude;
  final String status;
  final double confidenceScore;
  final String? wasteType;
  final String? dangerLevel;
  final String? adminNotes;
  final String createdAt;
  final String updatedAt;
  final ReporterProfile? reporterProfile;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.imageUrl,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.confidenceScore,
    this.wasteType,
    this.dangerLevel,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.reporterProfile,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    // Parse PostGIS location column (can be GeoJSON Map or WKT string)
    final loc = json['location'];
    if (loc is Map<String, dynamic>) {
      if (loc['type'] == 'Point' && loc['coordinates'] is List) {
        final coords = loc['coordinates'] as List;
        if (coords.length >= 2) {
          lng = (coords[0] as num).toDouble();
          lat = (coords[1] as num).toDouble();
        }
      }
    } else if (loc is String) {
      // WKT format: POINT(lng lat) or POINT(lng lat)
      // e.g. "POINT(106.8451 6.2088)"
      final match = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)', caseSensitive: false)
          .firstMatch(loc);
      if (match != null && match.groupCount >= 2) {
        lng = double.tryParse(match.group(1) ?? '0.0') ?? 0.0;
        lat = double.tryParse(match.group(2) ?? '0.0') ?? 0.0;
      }
    }

    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
      latitude: lat,
      longitude: lng,
      status: json['status'] as String? ?? 'pending_ai',
      confidenceScore: (json['confidence_score'] as num? ?? 0.0).toDouble(),
      wasteType: json['waste_type'] as String?,
      dangerLevel: json['danger_level'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      reporterProfile: json['profiles'] != null
          ? ReporterProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'image_url': imageUrl,
      'description': description,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'status': status,
      'confidence_score': confidenceScore,
      'waste_type': wasteType,
      'danger_level': dangerLevel,
      'admin_notes': adminNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ReporterProfile {
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  ReporterProfile({
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory ReporterProfile.fromJson(Map<String, dynamic> json) {
    return ReporterProfile(
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}
