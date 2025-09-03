import 'package:flutter/material.dart';
import 'package:desperdicio_zero/services/auth_service.dart';
import 'package:desperdicio_zero/utils/logger_util.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro - Desperdício Zero'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não conferem';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      logDebug('Botão de cadastro pressionado');
                      if (_formKey.currentState!.validate()) {
                        logInfo('Formulário validado com sucesso');
                        
                        // Mostra um indicador de carregamento
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final overlay = ScaffoldMessenger.of(context);
                        
                        try {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          final name = _nameController.text.trim();
                          
                          logInfo('Tentando cadastrar usuário: $email');
                          
                          final authService = AuthService.instance;
                          
                          // Mostra um diálogo de carregamento
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          
                          try {
                            // Tenta fazer o cadastro
                            await authService.signUpWithEmail(
                              email: email,
                              password: password,
                              name: name,
                            );
                            
                            logInfo('Usuário cadastrado com sucesso: $email');
                            
                            // Fecha o diálogo de carregamento
                            if (context.mounted) {
                              navigator.pop(); // Remove o diálogo de carregamento
                              
                              // Mostra mensagem de sucesso
                              await showDialog(
                                context: context,
                                barrierDismissible: false, // Impede fechar clicando fora
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Cadastro realizado com sucesso!'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Enviamos um e-mail de confirmação para:',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            email,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Por favor, verifique sua caixa de entrada (e a pasta de spam) e siga as instruções para ativar sua conta.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Volta para a tela de login
                                          Navigator.popUntil(context, (route) => route.isFirst);
                                        },
                                        child: const Text('OK, entendi'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            
                          } catch (e) {
                            logError('Erro durante o cadastro', e);
                            
                            // Fecha o diálogo de carregamento em caso de erro
                            if (context.mounted) {
                              navigator.pop(); // Remove o diálogo de carregamento
                              
                              // Determina a mensagem de erro
                              String errorMessage = 'Ocorreu um erro ao tentar se cadastrar. ';
                              
                              if (e.toString().contains('already registered')) {
                                errorMessage = 'Este e-mail já está cadastrado. Tente fazer login ou recuperar sua senha.';
                              } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
                                errorMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
                              } else if (e.toString().contains('invalid email')) {
                                errorMessage = 'Por favor, insira um endereço de e-mail válido.';
                              } else if (e.toString().contains('weak password')) {
                                errorMessage = 'A senha é muito fraca. Tente uma senha mais forte com pelo menos 6 caracteres.';
                              }
                              
                              // Mostra mensagem de erro detalhada
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Erro no Cadastro'),
                                    content: Text(
                                      errorMessage,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            
                            // Mostra mensagem de erro no console para depuração
                            logError('Detalhes do erro: $e');
                            
                            // Mostra mensagem de erro no snackbar também
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                  action: SnackBarAction(
                                    label: 'Fechar',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      messenger.hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                            }
                            logError('Erro durante o cadastro', e);
                          }
                          
                        } catch (e) {
                          logError('Erro inesperado', e);
                          if (context.mounted) {
                            overlay.showSnackBar(
                              const SnackBar(
                                content: Text('Ocorreu um erro inesperado. Tente novamente.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                    }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Cadastrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Já tem uma conta? Faça login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
