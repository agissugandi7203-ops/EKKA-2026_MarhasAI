import 'package:equatable/equatable.dart';
import '../../data/models/report_model.dart';
import '../../data/models/upload_report_response.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsFetchSuccess extends ReportsState {
  final List<ReportModel> reports;

  const ReportsFetchSuccess(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportUploadSuccess extends ReportsState {
  final UploadReportResponse response;

  const ReportUploadSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ReportsFailure extends ReportsState {
  final String message;

  const ReportsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
