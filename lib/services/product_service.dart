import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desperdicio_zero/models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all products for the current user
  Future<List<Product>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('expiration_date', ascending: true);
      
      return (response as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  // Get a single product by ID
  Future<Product> getProduct(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  // Add a new product
  Future<Product> addProduct(Product product) async {
    try {
      final productData = product.toJson()..['user_id'] = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao adicionar produto: $e');
    }
  }

  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }

  // Get products expiring soon (within X days)
  Future<List<Product>> getExpiringProducts(int daysAhead) async {
    try {
      final response = await _supabase
          .rpc('get_upcoming_expiries', params: {
            'user_uuid': _supabase.auth.currentUser!.id,
            'days_ahead': daysAhead,
          });
      
      return (response as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos próximos do vencimento: $e');
    }
  }
}
