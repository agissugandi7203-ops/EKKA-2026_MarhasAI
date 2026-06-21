import 'dart:io';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';
import '../models/report_model.dart';
import '../models/upload_report_response.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<UploadReportResponse> uploadReport({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    return await _remoteDataSource.uploadReport(
      imageFile: imageFile,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
  }

  @override
  Future<List<ReportModel>> getReports() async {
    return await _remoteDataSource.getReports();
  }
}
