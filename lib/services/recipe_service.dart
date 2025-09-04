import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desperdicio_zero/models/recipe_model.dart';

class RecipeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all recipes for the current user
  Future<List<Recipe>> getRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
            *,
            recipe_products (
              quantity,
              unit,
              products (*)
            )
          ''')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return (response as List).map((r) => Recipe.fromJson(r)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar receitas: $e');
    }
  }

  // Get a single recipe by ID with its products
  Future<Recipe> getRecipe(String id) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
            *,
            recipe_products (
              quantity,
              unit,
              products (*)
            )
          ''')
          .eq('id', id)
          .single();
      
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar receita: $e');
    }
  }

  // Add a new recipe with its products
  Future<Recipe> addRecipe(Recipe recipe) async {
    try {
      // Start a transaction
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');
      
      final recipeJson = recipe.toJson()..['user_id'] = currentUser.id;
      return await _supabase.rpc('add_recipe_with_products', params: {
        'p_recipe': recipeJson,
        'p_products': (recipe.products).map((p) => {
          'product_id': p.product?.id,
          'quantity': p.quantity,
          'unit': p.unit,
        }).toList(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar receita: $e');
    }
  }

  // Update a recipe
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      final response = await _supabase
          .from('recipes')
          .update(recipe.toJson())
          .eq('id', recipe.id)
          .select()
          .single();
      
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar receita: $e');
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    try {
      await _supabase
          .from('recipes')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir receita: $e');
    }
  }

  // Get recipes that can be made with available products
  Future<List<Recipe>> getPossibleRecipes() async {
    try {
      final response = await _supabase
          .rpc('get_possible_recipes', params: {
            'user_uuid': _supabase.auth.currentUser!.id,
          });
      
      return (response as List).map((r) => Recipe.fromJson(r)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar receitas possíveis: $e');
    }
  }
}
