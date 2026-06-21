import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/report_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportRepository _reportRepository;

  ReportsBloc({
    required ReportRepository reportRepository,
  })  : _reportRepository = reportRepository,
        super(ReportsInitial()) {
    on<FetchReportsRequested>(_onFetchReportsRequested);
    on<UploadReportRequested>(_onUploadReportRequested);
  }

  Future<void> _onFetchReportsRequested(
    FetchReportsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final reports = await _reportRepository.getReports();
      emit(ReportsFetchSuccess(reports));
    } catch (e) {
      emit(ReportsFailure(e.toString()));
    }
  }

  Future<void> _onUploadReportRequested(
    UploadReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final response = await _reportRepository.uploadReport(
        imageFile: event.imageFile,
        latitude: event.latitude,
        longitude: event.longitude,
        description: event.description,
      );
      emit(ReportUploadSuccess(response));
    } catch (e) {
      emit(ReportsFailure(e.toString()));
    }
  }
}
