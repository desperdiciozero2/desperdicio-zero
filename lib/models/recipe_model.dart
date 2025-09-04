import 'package:desperdicio_zero/models/product_model.dart';

class RecipeProduct {
  final String id;
  final String recipeId;
  final String productId;
  final num quantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  RecipeProduct({
    required this.id,
    required this.recipeId,
    required this.productId,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory RecipeProduct.fromJson(Map<String, dynamic> json) {
    return RecipeProduct(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as num,
      unit: json['unit'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      product: json['products'] != null ? Product.fromJson(json['products']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'product_id': productId,
      'quantity': quantity,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (product != null) 'products': product!.toJson(),
    };
  }
}

class Recipe {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String instructions;
  final int? prepTime; // em minutos
  final int? cookTime; // em minutos
  final int? servings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RecipeProduct> products;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.instructions,
    this.prepTime,
    this.cookTime,
    this.servings,
    required this.createdAt,
    required this.updatedAt,
    List<RecipeProduct>? products,
  }) : products = products ?? [];

  // Legacy getters for compatibility
  String get receita => title;
  String get modoPreparo => instructions;
  String? get linkImagem => imageUrl;
  
  // For backward compatibility
  List<IngredienteBase> get ingredientesBase => products.map((p) => IngredienteBase(
        id: p.id.hashCode,
        nomesIngrediente: [p.product?.name ?? 'Ingrediente'],
        receitaId: int.tryParse(id) ?? 0,
      )).toList();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Receita sem nome',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      instructions: json['instructions'] as String? ?? '',
      prepTime: json['prep_time'] as int?,
      cookTime: json['cook_time'] as int?,
      servings: json['servings'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      products: (json['recipe_products'] as List<dynamic>?)
          ?.map((e) => RecipeProduct.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'instructions': instructions,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'recipe_products': products.map((p) => p.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? imageUrl,
    String? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RecipeProduct>? products,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      products: products ?? this.products,
    );
  }

  // Mantendo compatibilidade
  List<String> get listaDeIngredientes => products
      .map((p) => '${p.quantity} ${p.unit} de ${p.product?.name ?? 'ingrediente'}')
      .toList();
}

class Nutrition {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const Nutrition({this.calories, this.protein, this.carbs, this.fat});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class IngredienteBase {
  final int id;
  final List<String> nomesIngrediente;
  final int receitaId;
  final double? quantidade;
  final String? unidade;

  const IngredienteBase({
    required this.id,
    required this.nomesIngrediente,
    required this.receitaId,
    this.quantidade,
    this.unidade,
  });

  factory IngredienteBase.fromJson(Map<String, dynamic> json) {
    return IngredienteBase(
      id: json['id'] as int,
      nomesIngrediente: List<String>.from((json['nomesIngrediente'] as List<dynamic>?) ?? []),
      receitaId: json['receitaId'] as int? ?? 0,
      quantidade: (json['quantidade'] as num?)?.toDouble(),
      unidade: json['unidade'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomesIngrediente': nomesIngrediente,
      'receitaId': receitaId,
      'quantidade': quantidade,
      'unidade': unidade,
    };
  }
}
