import 'dart:convert';

class RecipeIngredient {
  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.quantity,
    required this.isMain,
    required this.isCritical,
  });

  final int id;
  final String name;
  final String emoji;
  final String category;
  final String quantity;
  final bool isMain;
  final bool isCritical;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      isMain: _parseBool(json['is_main']),
      isCritical: _parseBool(json['is_critical']),
    );
  }

  Map<String, dynamic> toCookingMap() {
    return {
      'name': name,
      'amount': quantity,
      'unit': '',
      'emoji': emoji,
      'category': category,
      'isMain': isMain,
      'isCritical': isCritical,
    };
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

List<String> _parseInstructions(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {
      return [value];
    }
  }

  return const <String>[];
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.time,
    required this.difficulty,
    required this.category,
    required this.servings,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.ingredients,
    required this.instructions,
    this.matchScore,
    this.ingredientsHave = const <String>[],
    this.ingredientsMissing = const <String>[],
  });

  final int id;
  final String title;
  final String image;
  final String description;
  final int time;
  final String difficulty;
  final String category;
  final int servings;
  final bool isVegetarian;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int? matchScore;
  final List<String> ingredientsHave;
  final List<String> ingredientsMissing;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['name'] ?? '') as String,
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      time: (json['time'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      category: json['category'] as String? ?? 'General',
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      isLactoseFree: json['is_lactose_free'] as bool? ?? false,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RecipeIngredient.fromJson)
          .toList(),
      instructions: _parseInstructions(json['instructions']),
      matchScore: (json['match_score'] as num?)?.toInt(),
      ingredientsHave: (json['ingredients_have'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      ingredientsMissing:
          (json['ingredients_missing'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
    );
  }

  factory Recipe.fromDynamic(dynamic value) {
    if (value is Recipe) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      return Recipe.fromJson(value);
    }

    throw ArgumentError('Unsupported recipe payload: $value');
  }

  List<String> get availableIngredients {
    if (ingredientsHave.isNotEmpty) {
      return ingredientsHave;
    }

    return ingredients.map((ingredient) => ingredient.name).toList();
  }

  List<Map<String, dynamic>> get cookingSteps {
    return instructions.asMap().entries.map((entry) {
      return {
        'instruction': entry.value,
        'image': image,
      };
    }).toList();
  }
}
