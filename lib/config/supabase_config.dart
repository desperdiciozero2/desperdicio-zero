import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.get('SUPABASE_URL');
  static String get anonKey => dotenv.get('SUPABASE_ANON_KEY');
  static String get redirectUrl => dotenv.get('SUPABASE_REDIRECT_URL');
  static String get resetPasswordUrl =>
      dotenv.get('SUPABASE_RESET_PASSWORD_URL');

  // Configurações de tempo limite (opcional)
  static const int authTimeout = 30; // segundos
  static const int refreshTokenThreshold = 60; // segundos

  // Configurações de armazenamento local (opcional)
  static const String localStorageKey = 'supabase.auth.token';

  // Nomes das tabelas no Supabase (ajuste conforme sua estrutura)
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
}
