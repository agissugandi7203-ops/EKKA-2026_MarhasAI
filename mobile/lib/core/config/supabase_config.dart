/// Konfigurasi Supabase — diambil dari environment variable saat build.
///
/// Credential diinjeksi via `--dart-define` saat menjalankan Flutter:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
/// ```
///
/// Atau di launch.json (VS Code):
/// ```json
/// "toolArgs": [
///   "--dart-define=SUPABASE_URL=https://xxx.supabase.co",
///   "--dart-define=SUPABASE_ANON_KEY=eyJhbGci..."
/// ]
/// ```
///
/// Ini menghindari hardcode credential di source code yang bisa
/// di-decompile dari APK/IPA.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_ID.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
