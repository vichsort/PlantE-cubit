import 'package:equatable/equatable.dart';

class FoodRecipe extends Equatable {
  final String name;
  final List<String> ingredients;
  const FoodRecipe({required this.name, required this.ingredients});

  factory FoodRecipe.fromJson(Map<String, dynamic> json) {
    return FoodRecipe(
      name: json['name'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
    );
  }
  @override
  List<Object?> get props => [name, ingredients];
}

class MedicinalUse extends Equatable {
  final String howToUse;
  final List<String> benefits;
  const MedicinalUse({required this.howToUse, required this.benefits});

  factory MedicinalUse.fromJson(Map<String, dynamic> json) {
    return MedicinalUse(
      howToUse: json['how_to_use'] as String,
      benefits: List<String>.from(json['benefits'] as List),
    );
  }
  @override
  List<Object?> get props => [howToUse, benefits];
}

class PlantNutritionalData extends Equatable {
  final List<String> tea;
  final FoodRecipe food;
  final MedicinalUse heal;
  final String seasoning;

  const PlantNutritionalData({
    required this.tea,
    required this.food,
    required this.heal,
    required this.seasoning,
  });

  factory PlantNutritionalData.fromJson(Map<String, dynamic> json) {
    return PlantNutritionalData(
      tea: List<String>.from(json['tea'] as List),
      food: FoodRecipe.fromJson(json['food'] as Map<String, dynamic>),
      heal: MedicinalUse.fromJson(json['heal'] as Map<String, dynamic>),
      seasoning: json['seasoning'] as String,
    );
  }

  @override
  List<Object?> get props => [tea, food, heal, seasoning];
}
