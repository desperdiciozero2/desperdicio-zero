import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desperdicio_zero/utils/logger_util.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final StreamController<Uri> _linkStreamController = StreamController<Uri>.broadcast();

  /// Inicializa o serviço de deep linking
  Future<void> initialize() async {
    // Configura o gerenciador de links do Supabase
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      logInfo('Auth state changed: $event');
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        logInfo('Usuário autenticado via deep link');
      }
    });
  }

  /// Retorna um stream de links recebidos
  Stream<Uri> get linkStream => _linkStreamController.stream;

  /// Adiciona um link ao stream
  void addLink(Uri uri) {
    _linkStreamController.add(uri);
  }

  /// Trata um deep link recebido
  Future<void> handleDeepLink(Uri? uri) async {
    if (uri == null) return;
    
    logInfo('Deep link recebido: $uri');
    
    // Verifica se é um link de confirmação de e-mail
    if (uri.scheme == 'com.example.desperdicio_zero' && 
        (uri.host == 'login-callback' || uri.host == 'reset-password')) {
      logInfo('Processando link de autenticação: ${uri.host}');
      
      try {
        // Verifica se o usuário já está autenticado
        final currentSession = _supabase.auth.currentSession;
        
        if (currentSession == null) {
          logInfo('Nenhuma sessão ativa. Redirecionando para a tela de login.');
          return;
        }
        
        // Atualiza a sessão para garantir que está válida
        await _supabase.auth.refreshSession();
        logInfo('Sessão atualizada com sucesso');
        
      } catch (e, stackTrace) {
        logError('Erro ao processar deep link de autenticação', e, stackTrace);
      }
    }
  }
  
  /// Libera recursos
  void dispose() {
    _linkStreamController.close();
  }
}
