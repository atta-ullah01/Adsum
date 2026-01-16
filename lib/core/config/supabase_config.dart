
abstract class SupabaseConfig {
  // TODO: Replace with your actual Supabase URL and Anon Key
  // For production, use String.fromEnvironment('SUPABASE_URL') 
  // and pass via --dart-define during build.
  
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL', 
  );
  
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
}
