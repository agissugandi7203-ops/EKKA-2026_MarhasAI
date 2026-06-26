import 'dart:io';
import '../../../../core/errors/error_handler.dart';
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
    try {
      return await _remoteDataSource.uploadReport(
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<List<ReportModel>> getReports() async {
    try {
      return await _remoteDataSource.getReports();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _remoteDataSource.deleteReport(reportId);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
