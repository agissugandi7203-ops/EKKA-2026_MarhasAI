import 'dart:io';
import '../../data/models/report_model.dart';
import '../../data/models/upload_report_response.dart';

abstract class ReportRepository {
  Future<UploadReportResponse> uploadReport({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? description,
  });

  Future<List<ReportModel>> getReports();
}
