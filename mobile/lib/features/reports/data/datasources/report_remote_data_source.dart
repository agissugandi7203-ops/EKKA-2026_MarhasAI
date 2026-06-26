import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/report_model.dart';
import '../models/upload_report_response.dart';

abstract class ReportRemoteDataSource {
  Future<UploadReportResponse> uploadReport({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? description,
  });

  Future<List<ReportModel>> getReports();

  Future<void> deleteReport(String reportId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient _dioClient;

  ReportRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UploadReportResponse> uploadReport({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final fileName = imageFile.path.split(RegExp(r'[/\\]')).last;
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (description != null && description.isNotEmpty) 'description': description,
    });

    final response = await _dioClient.dio.post(
      '/reports',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return UploadReportResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ReportModel>> getReports() async {
    final response = await _dioClient.dio.get('/reports');
    final list = response.data as List? ?? [];
    return list.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteReport(String reportId) async {
    await _dioClient.dio.delete('/reports/$reportId');
  }
}
