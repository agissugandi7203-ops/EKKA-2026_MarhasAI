import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class FetchReportsRequested extends ReportsEvent {}

class UploadReportRequested extends ReportsEvent {
  final File imageFile;
  final double latitude;
  final double longitude;
  final String? description;

  const UploadReportRequested({
    required this.imageFile,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  @override
  List<Object?> get props => [imageFile, latitude, longitude, description];
}

class DeleteReportRequested extends ReportsEvent {
  final String reportId;

  const DeleteReportRequested(this.reportId);

  @override
  List<Object?> get props => [reportId];
}
