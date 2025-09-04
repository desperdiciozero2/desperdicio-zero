import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desperdicio_zero/services/notification_service.dart';
import 'package:desperdicio_zero/services/spoonacular_service.dart';
import 'package:desperdicio_zero/services/deep_link_service.dart';
import 'package:desperdicio_zero/screens/login_screen.dart';
import 'package:desperdicio_zero/screens/register_screen.dart';
import 'package:desperdicio_zero/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desperdicio_zero/screens/forgot_password_screen.dart';
import 'package:desperdicio_zero/screens/reset_password_screen.dart';
import 'package:desperdicio_zero/screens/splash_screen.dart';
import 'package:desperdicio_zero/config/supabase_config.dart';
import 'package:desperdicio_zero/utils/logger_util.dart';
import 'package:desperdicio_zero/providers/providers.dart';
import 'dart:async';
import 'package:desperdicio_zero/models/auth_state.dart';

// Inicializa o serviço de notificações
final notificationService = NotificationService();

// Função principal assíncrona para inicializar recursos
Future<void> main() async {
  // Garante que o binding do Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Inicializa o Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  // Obtém a instância do cliente Supabase
  final supabase = Supabase.instance.client;
  
  // Configura o redirecionamento para autenticação
  final redirectUrl = '${Uri.base.scheme}://${Uri.base.host}${Uri.base.port != 80 ? ':${Uri.base.port}' : ''}/auth/callback';
  logDebug('URL de redirecionamento: $redirectUrl');
  
  // Configura o listener de mudanças de autenticação
  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    logDebug('Auth event: $event, session: ${session != null ? 'present' : 'empty'}');
    
    if (event == AuthChangeEvent.signedIn && session != null) {
      final email = session.user.email ?? "E-mail não disponível";
      logInfo('Usuário autenticado: $email');
    } else if (event == AuthChangeEvent.signedOut) {
      logInfo('Usuário deslogado');
    }
  });

  // Inicializa o serviço de notificações
  await notificationService.initialize();

  // Inicializa o logger
  LoggerUtil.initialize();
  
  // Configura o logging
  setupLogging();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final DeepLinkService _deepLinkService;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  Future<void> _initDeepLinking() async {
    _deepLinkService = DeepLinkService();
    await _deepLinkService.initialize();

    // Listen to deep links while app is running
    _linkSubscription = _deepLinkService.linkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    logInfo('Deep link received in main: $uri');
    
    if (!mounted) return;
    
    try {
      // Handle different deep link paths
      if (uri.host == 'reset-password' || uri.host == 'recover') {
        logInfo('Handling password reset deep link');
        
        // Tenta extrair o token do fragmento primeiro
        String? accessToken;
        String? tokenType;
        
        // Verifica se há fragmento na URL
        if (uri.fragment.isNotEmpty) {
          final params = Uri.splitQueryString(uri.fragment);
          accessToken = params['access_token'];
          tokenType = params['token_type'];
          logInfo('Params from fragment - Token: ${accessToken != null ? 'present' : 'missing'}, Type: $tokenType');
        }
        
        // Se não encontrou no fragmento, tenta nos parâmetros de consulta
        if (accessToken == null) {
          accessToken = uri.queryParameters['access_token'];
          tokenType = uri.queryParameters['token_type'];
          logInfo('Params from query - Token: ${accessToken != null ? 'present' : 'missing'}, Type: $tokenType');
        }
        
        if (accessToken != null && tokenType != null) {
          logInfo('Valid recovery token found');
          
          // Navega para a tela de redefinição de senha
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              '/reset-password',
              (route) => false, // Remove todas as rotas anteriores
              arguments: {
                'accessToken': accessToken,
                'tokenType': tokenType,
              },
            );
            return;
          }
        } else {
          logError('Missing access token or token type in deep link');
          // Mostra mensagem de erro para o usuário
          if (navigatorKey.currentState?.mounted ?? false) {
            ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
              const SnackBar(
                content: Text('Link de redefinição inválido. Por favor, solicite um novo link.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else if (uri.host == 'login-callback' || uri.host == 'confirm-email') {
        logInfo('Login/confirmation callback received, handling auth state change');
        // O DeepLinkService irá lidar com isso
      }
    } catch (e, stackTrace) {
      logError('Error handling deep link: $uri', e, stackTrace);
      // Show error to user if possible
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar o link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
      // Determine initial route based on authentication state
    String initialRoute = '/splash';
    if (authState is AuthStateAuthenticated) {
      initialRoute = '/home';
    } else if (authState is AuthStateUnauthenticated) {
      initialRoute = '/splash';
    } else if (authState is AuthStateLoading) {
      initialRoute = '/splash';
    }

    return MaterialApp(
      title: 'Desperdício Zero',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ResetPasswordScreen(
            accessToken: args?['accessToken'],
            tokenType: args?['tokenType'],
          );
        },
      },
    );
  }
}

