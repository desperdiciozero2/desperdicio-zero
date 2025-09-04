import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  
  ProductNotifier(this._productService) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _productService.getProducts();
      state = AsyncValue.data(products);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productService.addProduct(product);
      await loadProducts();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

final productsProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
  (ref) => ProductNotifier(ref.watch(productServiceProvider)),
);
