/// ============================================
/// MODELO: REFEIÇÃO
/// ============================================
class Meal {
  final String id;
  final MealType type;
  final DateTime dateTime;
  final List<FoodItem> foods;
  final String? notes;
  final String? photoPath;

  const Meal({
    required this.id,
    required this.type,
    required this.dateTime,
    this.foods = const [],
    this.notes,
    this.photoPath,
  });

  double? get estimatedCalories {
    if (foods.isEmpty) return null;
    final hasAllCalories = foods.every((food) => food.calories != null);
    if (!hasAllCalories) return null;
    double total = 0.0;
    for (final food in foods) {
      total += food.calories ?? 0.0;
    }
    return total;
  }

  String get foodsSummary {
    if (foods.isEmpty) return 'Nenhum alimento registrado';
    return foods.map((f) => f.name).join(', ');
  }

  Meal copyWith({
    String? id,
    MealType? type,
    DateTime? dateTime,
    List<FoodItem>? foods,
    String? notes,
    String? photoPath,
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      foods: foods ?? this.foods,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

// ============================================
// MODELO: ALIMENTO
// ============================================
class FoodItem {
  final String name;
  final double quantity;
  final String unit;
  final double? calories;

  const FoodItem({
    required this.name,
    required this.quantity,
    this.unit = 'g',
    this.calories,
  });

  String get display {
    final qty = quantity.truncate() == quantity
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(1);
    return '$name — $qty $unit';
  }

  FoodItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? calories,
  }) {
    return FoodItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
    );
  }
}

// ============================================
// ENUM: TIPO DE REFEIÇÃO
// ============================================
enum MealType {
  breakfast,
  morningSnack,
  lunch,
  afternoonSnack,
  dinner,
  supper,
}

extension MealTypeExtension on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Café da manhã';
      case MealType.morningSnack:
        return 'Lanche da manhã';
      case MealType.lunch:
        return 'Almoço';
      case MealType.afternoonSnack:
        return 'Lanche da tarde';
      case MealType.dinner:
        return 'Jantar';
      case MealType.supper:
        return 'Ceia';
    }
  }

  String get shortLabel {
    switch (this) {
      case MealType.breakfast:
        return 'Café';
      case MealType.morningSnack:
        return 'Lanche';
      case MealType.lunch:
        return 'Almoço';
      case MealType.afternoonSnack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
      case MealType.supper:
        return 'Ceia';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '☕';
      case MealType.morningSnack:
        return '🍎';
      case MealType.lunch:
        return '🍽️';
      case MealType.afternoonSnack:
        return '🥪';
      case MealType.dinner:
        return '🌙';
      case MealType.supper:
        return '🥛';
    }
  }

  String get suggestedTime {
    switch (this) {
      case MealType.breakfast:
        return '07:00';
      case MealType.morningSnack:
        return '10:00';
      case MealType.lunch:
        return '12:30';
      case MealType.afternoonSnack:
        return '15:30';
      case MealType.dinner:
        return '19:00';
      case MealType.supper:
        return '21:30';
    }
  }
}