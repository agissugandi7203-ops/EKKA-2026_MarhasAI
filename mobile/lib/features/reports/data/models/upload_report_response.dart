import 'report_model.dart';

class UploadReportResponse {
  final bool isDuplicate;
  final String message;
  final ReportModel? report;
  final String? duplicateReportId;

  UploadReportResponse({
    required this.isDuplicate,
    required this.message,
    this.report,
    this.duplicateReportId,
  });

  factory UploadReportResponse.fromJson(Map<String, dynamic> json) {
    return UploadReportResponse(
      isDuplicate: json['isDuplicate'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      report: json['report'] != null
          ? ReportModel.fromJson(json['report'] as Map<String, dynamic>)
          : null,
      duplicateReportId: json['duplicateReportId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDuplicate': isDuplicate,
      'message': message,
      'report': report?.toJson(),
      'duplicateReportId': duplicateReportId,
    };
  }
}
