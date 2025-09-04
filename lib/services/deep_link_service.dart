import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desperdicio_zero/utils/logger_util.dart' show LoggerUtil;

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final StreamController<Uri> _linkStreamController = StreamController<Uri>.broadcast();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Inicializa o serviço de deep linking
  Future<void> initialize() async {
    _appLinks = AppLinks();
    
    // Configura o gerenciador de links do Supabase
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      
      LoggerUtil.logger.info('Auth state changed: $event');
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        LoggerUtil.logger.info('Usuário autenticado via deep link');
        // Navega para a tela inicial após o login bem-sucedido
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        LoggerUtil.logger.info('Usuário deslogado');
        // Navega para a tela de login após o logout
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    });

    // Configura o listener para links profundos
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      LoggerUtil.logger.info('Link recebido: $uri');
      _linkStreamController.add(uri);
      await handleDeepLink(uri);
    });

    // Verifica se o app foi aberto por um link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        LoggerUtil.logger.info('App aberto por link: $initialUri');
        _linkStreamController.add(initialUri);
        await handleDeepLink(initialUri);
      } else {
        // Se não houver link inicial, verifica se há uma sessão ativa
        final currentSession = _supabase.auth.currentSession;
        if (currentSession != null) {
          // Atualiza a sessão para garantir que ainda é válida
          try {
            await _supabase.auth.refreshSession();
            LoggerUtil.logger.info('Sessão atualizada com sucesso');
          } catch (e) {
            LoggerUtil.logger.warning('Erro ao atualizar sessão', e);
            await _supabase.auth.signOut();
          }
        }
      }
    } catch (e) {
      LoggerUtil.logger.severe('Erro ao obter link inicial', e);
    }
  }

  /// Retorna um stream de links recebidos
  Stream<Uri> get linkStream => _linkStreamController.stream;

  /// Adiciona um link ao stream
  void addLink(Uri uri) {
    _linkStreamController.add(uri);
  }

  /// Trata um deep link recebido
  Future<void> handleDeepLink(Uri? uri) async {
    if (uri == null) {
      LoggerUtil.logger.warning('URI nula recebida no handleDeepLink');
      return;
    }
    
    LoggerUtil.logger.info('Processando deep link: $uri');
    LoggerUtil.logger.info('Esquema: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    
    // Verifica o esquema do link
    if (uri.scheme == 'com.example.desperdicio_zero' || 
        uri.scheme == 'https' || 
        uri.scheme == 'http') {
      
      // Verifica se é um link de redefinição de senha
      final isResetPasswordLink = 
          uri.host == 'reset-password' || 
          uri.host == 'recover' ||
          uri.path.contains('reset-password') ||
          uri.path.contains('recover') ||
          (uri.queryParameters['type']?.toLowerCase() == 'recovery');
      
      if (isResetPasswordLink) {
        LoggerUtil.logger.info('Link identificado como redefinição de senha');
        
        try {
          // Tenta extrair o token do fragmento primeiro
          String? accessToken;
          String? tokenType;
          
          // Verifica se há fragmento na URL
          if (uri.fragment.isNotEmpty) {
            final params = Uri.splitQueryString(uri.fragment);
            accessToken = params['access_token'] ?? params['token'];
            tokenType = params['token_type'] ?? params['type'];
            LoggerUtil.logger.info('Parâmetros extraídos do fragmento - Token: ${accessToken != null ? 'presente' : 'ausente'}, Tipo: $tokenType');
          }
          
          // Se não encontrou no fragmento, tenta nos parâmetros de consulta
          if (accessToken == null) {
            accessToken = uri.queryParameters['access_token'] ?? uri.queryParameters['token'];
            tokenType = uri.queryParameters['token_type'] ?? uri.queryParameters['type'];
            LoggerUtil.logger.info('Parâmetros extraídos da query - Token: ${accessToken != null ? 'presente' : 'ausente'}, Tipo: $tokenType');
          }
          
          if (accessToken != null && tokenType != null) {
            LoggerUtil.logger.info('Token de recuperação válido encontrado');
            
            // Tenta fazer login com o token
            try {
              LoggerUtil.logger.info('Configurando sessão com token: ${accessToken.substring(0, 10)}...');
              
              // Configura a sessão com o token
              await _supabase.auth.setSession(accessToken);
              LoggerUtil.logger.info('Sessão atualizada com sucesso via deep link');
              
              // Verifica se a sessão foi configurada corretamente
              final currentUser = _supabase.auth.currentUser;
              if (currentUser != null) {
                LoggerUtil.logger.info('Usuário autenticado: ${currentUser.email}');
                
                // Navega para a tela de redefinição de senha
                if (navigatorKey.currentState != null) {
                  LoggerUtil.logger.info('Navegando para a tela de redefinição de senha');
                  
                  // Usa um pequeno delay para garantir que a navegação seja processada corretamente
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    '/reset-password',
                    (route) => false,
                    arguments: {
                      'accessToken': accessToken,
                      'tokenType': tokenType,
                    },
                  );
                } else {
                  LoggerUtil.logger.warning('navigatorKey.currentState é nulo');
                }
              } else {
                LoggerUtil.logger.warning('Falha ao configurar a sessão do usuário');
                _showErrorSnackBar('Falha ao processar o link de redefinição. Por favor, tente novamente.');
              }  return;
            } catch (e, stackTrace) {
              LoggerUtil.logger.severe('Erro ao atualizar sessão via deep link', e, stackTrace);
              // Continua mesmo com erro para tentar navegar
            }
          }
          
          // Se chegou aqui, algo deu errado, tenta navegar mesmo assim
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              '/reset-password',
              (route) => false,
              arguments: {
                'accessToken': accessToken,
                'tokenType': tokenType,
              },
            );
          }
          
        } catch (e, stackTrace) {
          LoggerUtil.logger.severe('Erro ao processar link de recuperação de senha', e, stackTrace);
          // Mostra mensagem de erro para o usuário se possível
          if (navigatorKey.currentState?.mounted ?? false) {
            ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao processar o link de redefinição de senha. Tente novamente.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      // Handle email confirmation and login callbacks
      else if (uri.host == 'login-callback' || uri.host == 'confirm-email') {
        LoggerUtil.logger.info('Processando link de confirmação de e-mail: $uri');
        
        try {
          // Extract token from URL fragment
          final fragment = uri.fragment;
          if (fragment.isNotEmpty) {
            final params = Uri.splitQueryString(fragment);
            final accessToken = params['access_token'];
            final tokenType = params['token_type'];
            // Type parameter is not used as we handle all confirmation types the same way
            
            if (accessToken != null && tokenType != null) {
              try {
                // Set the session with the access token
                await _supabase.auth.setSession(accessToken);
                LoggerUtil.logger.info('E-mail confirmado com sucesso');
                
                // Navigate to home screen after successful confirmation
                if (navigatorKey.currentState != null) {
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  );
                }
                return;
              } catch (e, stackTrace) {
                LoggerUtil.logger.severe('Erro ao confirmar e-mail', e, stackTrace);
                // If there's an error, still try to refresh the session
              }
            }
          }
          
          // Fallback to refresh session if token handling fails
          final currentSession = _supabase.auth.currentSession;
          if (currentSession != null) {
            await _supabase.auth.refreshSession();
            LoggerUtil.logger.info('Sessão atualizada com sucesso');
            
            // Navigate to home after session refresh
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            }
          } else {
            LoggerUtil.logger.info('Nenhuma sessão ativa. Redirecionando para login.');
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }
          
        } catch (e, stackTrace) {
          LoggerUtil.logger.severe('Erro ao processar confirmação de e-mail', e, stackTrace);
        }
      }
    }
  }
  
  /// Exibe uma mensagem de erro em um SnackBar
  void _showErrorSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      LoggerUtil.logger.warning('Não foi possível exibir a mensagem de erro: contexto nulo ou não montado');
    }
  }

  /// Libera recursos
  void dispose() {
    _linkSubscription?.cancel();
    _linkStreamController.close();
  }
}
