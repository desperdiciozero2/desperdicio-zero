import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desperdicio_zero/models/product_model.dart';
import 'package:desperdicio_zero/providers/product_provider.dart';
import 'package:desperdicio_zero/screens/add_product_screen.dart';
import 'package:desperdicio_zero/services/auth_service.dart';
import 'package:desperdicio_zero/providers/auth_provider.dart';
import 'package:desperdicio_zero/screens/recipes_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await ref.read(productsProvider.notifier).loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'Nenhum produto adicionado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Toque no botão + para adicionar seu primeiro produto',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _navigateToAddProduct,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Adicionar Produto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddProduct() async {
    if (!mounted) return;
    
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onProductAdded: (product) => product,
        ),
      ),
    );
    
    if (newProduct != null && mounted) {
      await _addProduct(newProduct);
    }
  }

  Future<void> _addProduct(Product product) async {
    if (!mounted) return;
    
    final context = this.context; // Capture context before async gap
    
    try {
      await ref.read(productsProvider.notifier).addProduct(product);
      if (!mounted) return;
      
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto adicionado com sucesso!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar produto: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await ref.read(productsProvider.notifier).deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto removido com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover produto: $e')),
        );
      }
    }
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(product.expirationDate!)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(product),
            ),
            onTap: () {
              // Handle product tap (e.g., edit product)
            },
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desperdício Zero'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipesScreen(),
                ),
              );
            },
            tooltip: 'Ver Receitas',
          ),
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  try {
                    final authService = AuthService();
                    await authService.signOut();
                    
                    // Navega para a tela de login após o logout bem-sucedido
                    if (mounted) {
                      // Força a atualização do estado de autenticação
                      ref.invalidate(authStateProvider);
                      
                      // Navega para a tela de login
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao fazer logout: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Tentar novamente',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              // Tenta fazer logout novamente
                              Navigator.of(context).popAndPushNamed('/login');
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                tooltip: 'Sair',
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Erro ao carregar produtos'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProducts,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return _buildEmptyState();
            }
            return _buildProductList(products);
          },
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddProduct,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
