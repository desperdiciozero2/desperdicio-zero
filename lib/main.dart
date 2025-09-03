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
import 'package:desperdicio_zero/screens/splash_screen.dart';
import 'package:desperdicio_zero/config/supabase_config.dart';
import 'package:desperdicio_zero/utils/logger_util.dart';
import 'package:desperdicio_zero/providers/providers.dart';
import 'dart:async';

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
  
  // Configura a URL de redirecionamento
  supabase.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedIn) {
      logInfo('Usuário autenticado com sucesso');
    }
  });

  // Inicializa o serviço de notificações
  await notificationService.initialize();

  // Inicializa o logger
  LoggerUtil.initialize();
  
  // Configura o logging
  setupLogging();
  
  // Inicializa o serviço de deep links
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  
  // Configura o listener de deep links
  _setupDeepLinkListener(deepLinkService);

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // Determina a rota inicial com base no estado de autenticação
    String initialRoute = '/splash';
    if (authState is Authenticated) {
      initialRoute = '/home';
    } else if (authState is Unauthenticated) {
      initialRoute = '/login';
    }

    return MaterialApp(
      title: 'Desperdício Zero',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}

// Configura o listener de deep links
void _setupDeepLinkListener(DeepLinkService deepLinkService) {
  // Configura o URL Strategy para web
  // Isso é necessário para que o Supabase saiba como lidar com os callbacks
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    
    logInfo('Auth state changed: $event');
    
    if (event == AuthChangeEvent.signedIn && session != null) {
      logInfo('Usuário autenticado via deep link');
      // Aqui você pode adicionar lógica adicional após o login
    }
  });
  
  // Configura o tratamento de links profundos
  // O próprio Supabase gerencia os callbacks de autenticação
  // Então não precisamos fazer nada adicional aqui
}
