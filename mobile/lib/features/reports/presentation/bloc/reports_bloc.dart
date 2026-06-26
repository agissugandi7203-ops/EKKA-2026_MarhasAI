import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/report_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportRepository _reportRepository;

  ReportsBloc({
    required ReportRepository reportRepository,
  })  : _reportRepository = reportRepository,
        super(ReportsInitial()) {
    on<FetchReportsRequested>(_onFetchRequestedOrDeleted);
    on<UploadReportRequested>(_onUploadReportRequested);
    on<DeleteReportRequested>(_onDeleteReportRequested);
  }

  // Rename _onFetchReportsRequested to reuse for fetch/delete or handle fetch separately
  Future<void> _onFetchReportsRequested(
    FetchReportsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final reports = await _reportRepository.getReports();
      emit(ReportsFetchSuccess(reports));
    } catch (e) {
      final appError = ErrorHandler.handle(e);
      emit(ReportsFailure(appError.message));
    }
  }

  // Helper/alias to avoid deprecation or handle FetchReportsRequested
  Future<void> _onFetchRequestedOrDeleted(
    FetchReportsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    await _onFetchReportsRequested(event, emit);
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
      final appError = ErrorHandler.handle(e);
      emit(ReportsFailure(appError.message));
    }
  }

  Future<void> _onDeleteReportRequested(
    DeleteReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      await _reportRepository.deleteReport(event.reportId);
      final reports = await _reportRepository.getReports();
      emit(ReportsFetchSuccess(reports));
    } catch (e) {
      final appError = ErrorHandler.handle(e);
      emit(ReportsFailure(appError.message));
    }
  }
}
