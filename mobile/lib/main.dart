import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/setup/presentation/bloc/setup_cubit.dart';

/// Entry point aplikasi Genesis.id.
///
/// Inisialisasi:
/// 1. Supabase SDK
/// 2. Dependency Injection (manual — tanpa library DI)
/// 3. MultiBlocProvider untuk state management global
/// 4. GoRouter untuk navigasi
/// 5. Material 3 Theme dari design system
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  /// Repositories.
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;

  /// BLoCs.
  late final AuthBloc _authBloc;

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

    // ── Repositories ──
    _authRepository = AuthRepositoryImpl(_authDataSource);
    _profileRepository = ProfileRepositoryImpl(_profileDataSource);

    // ── BLoCs ──
    _authBloc = AuthBloc(
      authRepository: _authRepository,
      profileRepository: _profileRepository,
    )..add(AuthCheckRequested());

    // ── Router ──
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<ProfileRepository>.value(value: _profileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<SetupCubit>(create: (_) => SetupCubit()),
        ],
        child: MaterialApp.router(
          title: 'Genesis.id',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
