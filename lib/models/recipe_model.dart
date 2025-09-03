class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String> ingredients;
  final String instructions;
  final int? prepTime; // em minutos
  final int? cookTime; // em minutos
  final int? servings;
  final Nutrition? nutrition;
  final bool isFavorite;
  final String? tipo; // Mantendo compatibilidade com o código existente

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.nutrition,
    this.isFavorite = false,
    this.tipo,
  });

  // Mantendo compatibilidade com o código existente
  String get receita => title;
  String get modoPreparo => _formatInstructionsForDisplay(instructions);
  String? get linkImagem => imageUrl;
  List<IngredienteBase> get ingredientesBase => ingredients
      .map(
        (ing) => IngredienteBase(
          id: ing.hashCode,
          nomesIngrediente: [ing],
          receitaId: id,
        ),
      )
      .toList();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Receita sem nome',
      description:
          json['description'] ??
          json['summary']?.replaceAll(RegExp(r'<[^>]*>'), ''),
      imageUrl: json['imageUrl'] ?? json['image'],
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['extendedIngredients'] as List<dynamic>?)
              ?.map(
                (e) => e is Map
                    ? '${e['amount']} ${e['unit']} ${e['name']}'.trim()
                    : e.toString(),
              )
              .toList() ??
          [],
      instructions: _formatInstructions(
        json['instructions'],
        json['analyzedInstructions'],
      ),
      prepTime: json['prepTime'] ?? json['readyInMinutes'],
      cookTime: json['cookTime'] ?? json['cookingMinutes'],
      servings: json['servings'],
      nutrition: json['nutrition'] != null
          ? Nutrition.fromJson(json['nutrition'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
      tipo: json['tipo'] ?? 'geral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'nutrition': nutrition?.toJson(),
      'isFavorite': isFavorite,
      'tipo': tipo,
    };
  }

  // Formata as instruções para exibição
  static String _formatInstructionsForDisplay(String instructions) {
    // Adiciona quebras de linha após pontos finais, exceto em abreviações comuns
    var formatted = instructions
        .replaceAllMapped(
          RegExp(
            r'(?<!\.\s)(?<!\.\d)(?<![A-Za-z]\.)(?<!\.)(?<!\. )(?<![A-Za-z]\.[A-Za-z])\.(?!\w|\.)(?!\s*[)}\]])(?=\s*[A-Z])',
          ),
          (match) => '.\n\n',
        )
        // Remove múltiplas quebras de linha
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        // Remove espaços em branco extras
        .replaceAll(RegExp(r' +'), ' ')
        .trim();

    return formatted;
  }

  // Formata as instruções da receita a partir dos dados da API
  static String _formatInstructions(
    dynamic instructions,
    dynamic analyzedInstructions,
  ) {
    if (instructions is String) {
      // Remove tags HTML e formata o texto
      return instructions
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    if (analyzedInstructions is List) {
      return analyzedInstructions
          .expand(
            (i) =>
                (i['steps'] as List?)?.map(
                  (s) => '${s['number']}. ${s['step']}',
                ) ??
                <String>[],
          )
          .join('\n\n');
    }

    return 'Instruções não disponíveis';
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    String? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    Nutrition? nutrition,
    bool? isFavorite,
    String? tipo,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      nutrition: nutrition ?? this.nutrition,
      isFavorite: isFavorite ?? this.isFavorite,
      tipo: tipo ?? this.tipo,
    );
  }

  // Mantendo compatibilidade
  List<String> get listaDeIngredientes => ingredients;
}

class Nutrition {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  Nutrition({this.calories, this.protein, this.carbs, this.fat});

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
  final DateTime? dataCriacao;

  IngredienteBase({
    required this.id,
    required this.nomesIngrediente,
    required this.receitaId,
    this.dataCriacao,
  });

  factory IngredienteBase.fromJson(Map<String, dynamic> json) {
    return IngredienteBase(
      id: json['id'] ?? 0,
      nomesIngrediente: List<String>.from(
        json['nomesIngrediente']?.map((e) => e.toString()) ?? [],
      ),
      receitaId: json['receita_id'] ?? 0,
      dataCriacao: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomesIngrediente': nomesIngrediente,
      'receita_id': receitaId,
      'created_at': dataCriacao?.toIso8601String(),
    };
  }
}
