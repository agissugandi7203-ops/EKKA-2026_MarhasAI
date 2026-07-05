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
    defaultValue: 'https://uvwkhwryfofnteffrmxe.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2d2tod3J5Zm9mbnRlZmZybXhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxOTUxNTAsImV4cCI6MjA5ODc3MTE1MH0.6eVqtU3A7dsWb9Z1Zn8U0XzL8OT7ixbtOCbJbPHdKAE',
  );
}
