import 'package:flutter/material.dart';
import 'package:desperdicio_zero/screens/products_list_screen.dart';
import 'package:desperdicio_zero/screens/add_product_screen.dart';
import 'package:desperdicio_zero/screens/recipes_screen.dart';
import 'package:desperdicio_zero/models/product_model.dart';
import 'package:desperdicio_zero/services/notification_service.dart';
import 'package:desperdicio_zero/services/auth_service.dart';
import 'package:intl/intl.dart' show DateFormat;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Product> _products = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addProduct(Product product) async {
    if (!mounted) return;
    
    setState(() {
      _products.add(product);
    });

    // Agenda notificação para o produto adicionado
    if (product.expirationDate != null) {
      final notificationService = NotificationService();

      try {
        // Notifica 1 dia antes do vencimento
        await notificationService.scheduleProductExpirationNotification(
          id: product.id.hashCode,
          title: 'Produto perto do vencimento!',
          body:
              'O produto ${product.name} vence em breve (${DateFormat('dd/MM/yyyy').format(product.expirationDate!)}).',
          expirationDate: product.expirationDate!,
          daysBefore: 1,
        );

        // Notifica no dia do vencimento
        await notificationService.scheduleProductExpirationNotification(
          id: product.id.hashCode,
          title: 'Produto vencendo hoje!',
          body: 'O produto ${product.name} vence hoje!',
          expirationDate: product.expirationDate!,
          daysBefore: 0,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao agendar notificações para o produto.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _toggleProductStatus(Product product) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product.copyWith(isConsumed: !product.isConsumed);

        // Se o produto foi marcado como consumido, cancela as notificações
        if (_products[index].isConsumed) {
          final notificationService = NotificationService();
          notificationService.cancelNotification(
            product.id.hashCode,
            daysBefore: 1,
          );
          notificationService.cancelNotification(
            product.id.hashCode,
            daysBefore: 0,
          );
        }
      }
    });
  }

  void _deleteProduct(Product product) {
    setState(() {
      _products.removeWhere((p) => p.id == product.id);
    });

    // Cancela as notificações quando o produto é removido
    final notificationService = NotificationService();
    notificationService.cancelNotification(product.id.hashCode, daysBefore: 1);
    notificationService.cancelNotification(product.id.hashCode, daysBefore: 0);
  }

  // Método para testar notificação manualmente
  Future<void> _testNotification() async {
    final notificationService = NotificationService();

    // Agenda uma notificação para daqui a 5 segundos
    final testTime = DateTime.now().add(Duration(seconds: 5));

    await notificationService.scheduleProductExpirationNotification(
      id: -1, // ID negativo para não conflitar com produtos reais
      title: 'Notificação de teste',
      body: 'Esta é uma notificação de teste do Desperdício Zero!',
      expirationDate: testTime,
      daysBefore: 0,
    );

    // Mostra um snackbar de confirmação
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notificação de teste agendada para daqui a 5 segundos',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desperdício Zero'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _testNotification,
            tooltip: 'Testar notificação',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService.instance.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao fazer logout. Tente novamente.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _getBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                if (!mounted) return;
                
                try {
                  final newProduct = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(
                        onProductAdded: (newProduct) {
                          if (mounted) {
                            _addProduct(newProduct);
                          }
                        },
                      ),
                    ),
                  );

                  if (newProduct != null && mounted) {
                    await _addProduct(newProduct);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao adicionar produto. Tente novamente.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.shopping_cart),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: // Página inicial
        return _buildHomeContent();
      case 1: // Estatísticas
        return Center(
          child: Text('Em desenvolvimento - Página de Estatísticas'),
        );
      case 2: // Perfil
        return Center(child: Text('Em desenvolvimento - Página de Perfil'));
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final totalProducts = _products.length;
    final consumedProducts = _products.where((p) => p.isConsumed).length;
    final activeProducts = totalProducts - consumedProducts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo dos Produtos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildStatisticRow(
                    'Total de Produtos',
                    totalProducts.toString(),
                  ),
                  _buildStatisticRow(
                    'Produtos Ativos',
                    activeProducts.toString(),
                  ),
                  _buildStatisticRow('Consumidos', consumedProducts.toString()),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsListScreen(
                                  products: _products,
                                  onProductTapped: _toggleProductStatus,
                                  onProductDeleted: _deleteProduct,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child: Text('Ver Produtos'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final ingredients = _products
                                .where((p) => !p.isConsumed)
                                .map((p) => p.name)
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipesScreen(
                                  ingredients: ingredients,
                                  title: 'Receitas com seus produtos',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child: const Text('Ver Receitas'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Dicas para Reduzir o Desperdício',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildTipCard(
            'Organize sua despensa',
            'Mantenha os produtos mais antigos na frente para usá-los primeiro.',
            Icons.kitchen,
          ),
          _buildTipCard(
            'Aproveite os alimentos por completo',
            'Muitas partes que costumamos descartar são comestíveis e nutritivas.',
            Icons.recycling,
          ),
          _buildTipCard(
            'Congele os alimentos',
            'Se não for consumir logo, congele para aumentar a vida útil.',
            Icons.ac_unit,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
