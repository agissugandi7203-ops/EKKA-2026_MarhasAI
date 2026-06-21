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
    try {
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
    } on DioException catch (e) {
      throw Exception('Gagal mengunggah laporan: ${e.response?.data['message'] ?? e.message}');
    }
  }

  @override
  Future<List<ReportModel>> getReports() async {
    try {
      final response = await _dioClient.dio.get('/reports');
      final list = response.data as List? ?? [];
      return list.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal mendapatkan daftar laporan: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
