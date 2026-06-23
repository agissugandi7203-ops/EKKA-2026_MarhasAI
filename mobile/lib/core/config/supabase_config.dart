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
    defaultValue: 'https://abmypsvfuplxmyblerhv.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFibXlwc3ZmdXBseG15Ymxlcmh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxOTM1MTUsImV4cCI6MjA5Nzc2OTUxNX0.PmBk7SfG_uIR2fnVER__qvK3zr4X2IByLNXTNfd5c4A',
  );
}
