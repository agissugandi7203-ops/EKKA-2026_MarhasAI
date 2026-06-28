import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/genesis_error_widget.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/reports/data/datasources/report_remote_data_source.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/domain/repositories/report_repository.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Entry point aplikasi Genesis.id.
///
/// Inisialisasi:
/// 1. Global error handler (menangkap crash yang tidak terduga)
/// 2. Supabase SDK
/// 3. Dependency Injection (manual — tanpa library DI)
/// 4. MultiBlocProvider untuk state management global
/// 5. GoRouter untuk navigasi
/// 6. Material 3 Theme dari design system
void main() async {
  // ── Global Error Handler ──
  // Menangkap semua error Flutter & Dart yang tidak tertangkap,
  // mencegah Red Screen of Death dan blank screen di production.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Tangkap error framework Flutter (rendering, layout, gesture)
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('═══ FLUTTER ERROR ═══');
      debugPrint('Exception: ${details.exceptionAsString()}');
      debugPrint('Stack: ${details.stack}');
      // Di production, kirim ke crash reporting (Firebase Crashlytics, Sentry, dll)
    };

    // Override ErrorWidget.builder untuk menampilkan error screen yang ramah pengguna
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: GenesisErrorWidget(
          message: kDebugMode
              ? details.exceptionAsString()
              : 'Terjadi kesalahan internal aplikasi. Tim kami sedang memperbaikinya.',
          icon: Icons.bug_report_rounded,
          iconColor: AppColors.error,
        ),
      );
    };

    // Tangkap error asinkronus Dart yang lolos dari framework
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('═══ PLATFORM ERROR ═══');
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
      return true; // Tandai sebagai "ditangani" agar app tidak crash
    };

    // Status bar transparan agar splash screen gradient terlihat penuh
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Inisialisasi Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    runApp(const GenesisApp());
  }, (Object error, StackTrace stack) {
    // Fallback terakhir: error di luar zona Flutter
    debugPrint('═══ UNCAUGHT ZONE ERROR ═══');
    debugPrint('Error: $error');
    debugPrint('Stack: $stack');
  });
}

/// Root widget Genesis.id.
///
/// Menyediakan dependency injection dan state management global
/// ke seluruh widget tree.
class GenesisApp extends StatefulWidget {
  const GenesisApp({super.key});

  @override
  State<GenesisApp> createState() => _GenesisAppState();
}

class _GenesisAppState extends State<GenesisApp> {
  // ══════════════════════════════════════════════════════════════════════
  // DEPENDENCY INJECTION (Manual, Explicit, Testable)
  // ══════════════════════════════════════════════════════════════════════

  /// Supabase client instance.
  late final SupabaseClient _supabaseClient;

  /// Network client untuk API NestJS.
  late final DioClient _dioClient;

  /// Data sources.
  late final AuthRemoteDataSource _authDataSource;
  late final ProfileRemoteDataSource _profileDataSource;
  late final ChatRemoteDataSource _chatDataSource;
  late final ReportRemoteDataSource _reportDataSource;
  late final LeaderboardRemoteDataSource _leaderboardDataSource;

  /// Repositories.
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;
  late final ReportRepository _reportRepository;
  late final LeaderboardRepository _leaderboardRepository;

  /// BLoCs.
  late final AuthBloc _authBloc;
  late final ChatBloc _chatBloc;
  late final ReportsBloc _reportsBloc;

  /// Router.
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  void _initDependencies() {
    // ── Core ──
    _supabaseClient = Supabase.instance.client;
    _dioClient = DioClient();

    // ── Data Sources ──
    _authDataSource = AuthRemoteDataSourceImpl(_supabaseClient);
    _profileDataSource = ProfileRemoteDataSourceImpl(_dioClient);
    _chatDataSource = ChatRemoteDataSource(_dioClient);
    _reportDataSource = ReportRemoteDataSourceImpl(_dioClient);
    _leaderboardDataSource = LeaderboardRemoteDataSourceImpl(_dioClient);

    // ── Repositories ──
    _authRepository = AuthRepositoryImpl(_authDataSource);
    _profileRepository = ProfileRepositoryImpl(_profileDataSource);
    _reportRepository = ReportRepositoryImpl(_reportDataSource);
    _leaderboardRepository = LeaderboardRepositoryImpl(_leaderboardDataSource);

    // ── BLoCs ──
    _authBloc = AuthBloc(
      authRepository: _authRepository,
      profileRepository: _profileRepository,
    )..add(AuthCheckRequested());
    _chatBloc = ChatBloc(_chatDataSource);
    _reportsBloc = ReportsBloc(reportRepository: _reportRepository);

    // ── Router ──
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _chatBloc.close();
    _reportsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<ProfileRepository>.value(value: _profileRepository),
        RepositoryProvider<ReportRepository>.value(value: _reportRepository),
        RepositoryProvider<LeaderboardRepository>.value(value: _leaderboardRepository),
        RepositoryProvider<ChatRemoteDataSource>.value(value: _chatDataSource),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<ChatBloc>.value(value: _chatBloc),
          BlocProvider<ReportsBloc>.value(value: _reportsBloc),
        ],
        child: MaterialApp.router(
          title: 'Genesis',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
