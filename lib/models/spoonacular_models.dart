import 'recipe_model.dart';

class SpoonacularRecipe {
  final int id;
  final String title;
  final String? image;
  final String? summary;
  final String? instructions;
  final int? readyInMinutes;
  final int? servings;
  final List<SpoonacularIngredient>? extendedIngredients;
  final SpoonacularNutrition? nutrition;
  final List<SpoonacularAnalyzedInstruction>? analyzedInstructions;
  final List<String>? dishTypes;
  final List<String>? diets;
  final List<String>? cuisines;

  SpoonacularRecipe({
    required this.id,
    required this.title,
    this.image,
    this.summary,
    this.instructions,
    this.readyInMinutes,
    this.servings,
    this.extendedIngredients,
    this.nutrition,
    this.analyzedInstructions,
    this.dishTypes,
    this.diets,
    this.cuisines,
  });

  factory SpoonacularRecipe.fromJson(Map<String, dynamic> json) {
    return SpoonacularRecipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      summary: json['summary']?.replaceAll(RegExp(r'<[^>]*>'), ''),
      instructions: json['instructions'],
      readyInMinutes: json['readyInMinutes'],
      servings: json['servings'],
      extendedIngredients: json['extendedIngredients'] != null
          ? (json['extendedIngredients'] as List)
                .map((e) => SpoonacularIngredient.fromJson(e))
                .toList()
          : null,
      nutrition: json['nutrition'] != null
          ? SpoonacularNutrition.fromJson(json['nutrition'])
          : null,
      analyzedInstructions: json['analyzedInstructions'] != null
          ? (json['analyzedInstructions'] as List)
                .map((e) => SpoonacularAnalyzedInstruction.fromJson(e))
                .toList()
          : null,
      dishTypes: json['dishTypes'] != null
          ? List<String>.from(json['dishTypes'])
          : null,
      diets: json['diets'] != null ? List<String>.from(json['diets']) : null,
      cuisines: json['cuisines'] != null
          ? List<String>.from(json['cuisines'])
          : null,
    );
  }

  // Converte para o modelo de Recipe existente
  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      description: summary,
      imageUrl: image,
      ingredients:
          extendedIngredients
              ?.map(
                (ing) =>
                    '${ing.amount?.toStringAsFixed(1) ?? ''} ${ing.unit ?? ''} ${ing.nameClean ?? ing.name}',
              )
              .toList() ??
          [],
      instructions: _getFormattedInstructions(),
      prepTime: readyInMinutes,
      cookTime: readyInMinutes,
      servings: servings,
      nutrition: nutrition?.toNutrition(),
      isFavorite: false,
      tipo: dishTypes?.isNotEmpty == true ? dishTypes?.first : 'geral',
    );
  }

  String _getFormattedInstructions() {
    if (instructions?.isNotEmpty == true) {
      return instructions!;
    }

    if (analyzedInstructions?.isNotEmpty == true) {
      return analyzedInstructions!
          .expand((i) => i.steps)
          .map((step) => '${step.number}. ${step.step}')
          .join('\n\n');
    }

    return 'Instruções não disponíveis';
  }
}

class SpoonacularIngredient {
  final int id;
  final String name;
  final String? nameClean;
  final String? original;
  final double? amount;
  final String? unit;
  final String? unitShort;
  final String? unitLong;
  final String? image;

  SpoonacularIngredient({
    required this.id,
    required this.name,
    this.nameClean,
    this.original,
    this.amount,
    this.unit,
    this.unitShort,
    this.unitLong,
    this.image,
  });

  factory SpoonacularIngredient.fromJson(Map<String, dynamic> json) {
    return SpoonacularIngredient(
      id: json['id'],
      name: json['name'],
      nameClean: json['nameClean'],
      original: json['original'],
      amount: json['amount']?.toDouble(),
      unit: json['unit'],
      unitShort: json['unitShort'],
      unitLong: json['unitLong'],
      image: json['image'],
    );
  }
}

class SpoonacularNutrition {
  final List<SpoonacularNutrient>? nutrients;
  final List<SpoonacularIngredient>? ingredients;

  SpoonacularNutrition({this.nutrients, this.ingredients});

  factory SpoonacularNutrition.fromJson(Map<String, dynamic> json) {
    return SpoonacularNutrition(
      nutrients: json['nutrients'] != null
          ? (json['nutrients'] as List)
                .map((e) => SpoonacularNutrient.fromJson(e))
                .toList()
          : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map((e) => SpoonacularIngredient.fromJson(e))
                .toList()
          : null,
    );
  }

  Nutrition? toNutrition() {
    if (nutrients == null) return null;

    double? getNutrientValue(String name) {
      try {
        return double.tryParse(
          nutrients
                  ?.firstWhere(
                    (n) =>
                        n.name?.toLowerCase().contains(name.toLowerCase()) ==
                        true,
                    orElse: () => SpoonacularNutrient(amount: 0, name: name),
                  )
                  .amount
                  ?.toString() ??
              '0',
        );
      } catch (e) {
        return 0.0;
      }
    }

    return Nutrition(
      calories: getNutrientValue('calories'),
      protein: getNutrientValue('protein'),
      carbs: getNutrientValue('carbohydrate'),
      fat: getNutrientValue('fat'),
    );
  }
}

class SpoonacularNutrient {
  final String? name;
  final double? amount;
  final String? unit;
  final double? percentOfDailyNeeds;

  SpoonacularNutrient({
    this.name,
    this.amount,
    this.unit,
    this.percentOfDailyNeeds,
  });

  factory SpoonacularNutrient.fromJson(Map<String, dynamic> json) {
    return SpoonacularNutrient(
      name: json['name'],
      amount: json['amount']?.toDouble(),
      unit: json['unit'],
      percentOfDailyNeeds: json['percentOfDailyNeeds']?.toDouble(),
    );
  }
}

class SpoonacularAnalyzedInstruction {
  final String? name;
  final List<SpoonacularInstructionStep> steps;

  SpoonacularAnalyzedInstruction({this.name, required this.steps});

  factory SpoonacularAnalyzedInstruction.fromJson(Map<String, dynamic> json) {
    return SpoonacularAnalyzedInstruction(
      name: json['name'],
      steps: (json['steps'] as List)
          .map((e) => SpoonacularInstructionStep.fromJson(e))
          .toList(),
    );
  }
}

class SpoonacularInstructionStep {
  final int number;
  final String step;
  final List<SpoonacularIngredient>? ingredients;
  final List<SpoonacularEquipment>? equipment;
  final dynamic length;

  SpoonacularInstructionStep({
    required this.number,
    required this.step,
    this.ingredients,
    this.equipment,
    this.length,
  });

  factory SpoonacularInstructionStep.fromJson(Map<String, dynamic> json) {
    return SpoonacularInstructionStep(
      number: json['number'],
      step: json['step'],
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map((e) => SpoonacularIngredient.fromJson(e))
                .toList()
          : null,
      equipment: json['equipment'] != null
          ? (json['equipment'] as List)
                .map((e) => SpoonacularEquipment.fromJson(e))
                .toList()
          : null,
      length: json['length'],
    );
  }
}

class SpoonacularEquipment {
  final int id;
  final String name;
  final String? localizedName;
  final String? image;

  SpoonacularEquipment({
    required this.id,
    required this.name,
    this.localizedName,
    this.image,
  });

  factory SpoonacularEquipment.fromJson(Map<String, dynamic> json) {
    return SpoonacularEquipment(
      id: json['id'],
      name: json['name'],
      localizedName: json['localizedName'],
      image: json['image'],
    );
  }
}
