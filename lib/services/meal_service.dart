import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1/';

  // Get a random meal
  static Future<Meal?> getRandomMeal() async {
    try {
      debugPrint('🍽️  Buscando uma refeição aleatória...');
      final response = await http.get(
        Uri.parse('${_baseUrl}random.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = Meal.fromJson(data['meals'][0]);
          debugPrint('✅ Refeição aleatória encontrada: ${meal.name}');
          return meal;
        }
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar refeição aleatória: $e\n$stackTrace');
      return null;
    }
  }

  // Search meals by name
  static Future<List<Meal>> searchMeals(String query) async {
    try {
      debugPrint('🔍 Buscando refeições com o termo: $query');

      if (query.isEmpty) return [];

      final response = await http.get(
        Uri.parse('${_baseUrl}search.php?s=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = (data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList();
          debugPrint('✅ ${meals.length} refeições encontradas para: $query');
          return meals;
        }
        debugPrint('ℹ️ Nenhuma refeição encontrada para: $query');
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar refeições: $e\n$stackTrace');
      return [];
    }
  }

  // Get meal details by ID
  static Future<Meal?> getMealById(String id) async {
    try {
      debugPrint('🔍 Buscando detalhes da refeição ID: $id');

      if (id.isEmpty) return null;

      final response = await http.get(
        Uri.parse('${_baseUrl}lookup.php?i=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = Meal.fromJson(data['meals'][0]);
          debugPrint('✅ Detalhes da refeição encontrados: ${meal.name}');
          return meal;
        }
        debugPrint('ℹ️ Nenhuma refeição encontrada com o ID: $id');
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar detalhes da refeição: $e\n$stackTrace');
      return null;
    }
  }

  // List all meals by first letter
  static Future<List<Meal>> listMealsByFirstLetter(String letter) async {
    try {
      debugPrint('🔠 Listando refeições com a letra: $letter');

      if (letter.isEmpty) return [];

      final response = await http.get(
        Uri.parse('${_baseUrl}search.php?f=${letter[0]}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = (data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList();
          debugPrint(
            '✅ ${meals.length} refeições encontradas com a letra: $letter',
          );
          return meals;
        }
        debugPrint('ℹ️ Nenhuma refeição encontrada com a letra: $letter');
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao listar refeições por letra: $e\n$stackTrace');
      return [];
    }
  }

  // Get all meal categories
  static Future<List<MealCategory>> getCategories() async {
    try {
      debugPrint('📋 Buscando categorias de refeições...');

      final response = await http.get(
        Uri.parse('${_baseUrl}categories.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['categories'] != null) {
          final categories = (data['categories'] as List)
              .map((cat) => MealCategory.fromJson(cat))
              .toList();
          debugPrint('✅ ${categories.length} categorias encontradas');
          return categories;
        }
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar categorias: $e\n$stackTrace');
      return [];
    }
  }

  // Filter by main ingredient
  static Future<List<Meal>> filterByIngredient(String ingredient) async {
    try {
      debugPrint('🥕 Filtrando por ingrediente: $ingredient');

      if (ingredient.isEmpty) return [];

      final response = await http.get(
        Uri.parse('${_baseUrl}filter.php?i=$ingredient'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          // Primeiro obtém a lista básica de refeições
          final meals = (data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList();

          // Para cada refeição, busca os detalhes completos
          final detailedMeals = <Meal>[];
          for (final meal in meals) {
            final detailedMeal = await getMealById(meal.id);
            if (detailedMeal != null) {
              detailedMeals.add(detailedMeal);
            }
            // Adiciona um pequeno delay para não sobrecarregar a API
            await Future.delayed(const Duration(milliseconds: 100));
          }

          debugPrint(
            '✅ ${detailedMeals.length} refeições encontradas com o ingrediente: $ingredient',
          );
          return detailedMeals;
        }
        debugPrint(
          'ℹ️ Nenhuma refeição encontrada com o ingrediente: $ingredient',
        );
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao filtrar por ingrediente: $e\n$stackTrace');
      return [];
    }
  }
}
