/// ============================================
/// MODELO: PERFIL DO PACIENTE
/// ============================================
/// Representa os dados de um paciente no NutriFlow.
class PatientProfile {
  // ============================================
  // IDENTIFICAÇÃO
  // ============================================
  final String id;
  final String name;
  final String email;
  final String? phone;

  // ============================================
  // DADOS PESSOAIS
  // ============================================
  final DateTime? birthDate;
  final Gender? gender;

  // ============================================
  // DADOS CLÍNICOS
  // ============================================
  final double? heightCm;        // Altura em centímetros
  final double? initialWeightKg;  // Peso inicial (primeira consulta)
  final double? currentWeightKg;  // Peso atual
  final double? goalWeightKg;     // Meta de peso
  final double? waistCm;          // Circunferência abdominal
  final Goal? goal;               // Objetivo
  final ActivityLevel? activityLevel; // Nível de atividade física

  // ============================================
  // RESTRIÇÕES E PREFERÊNCIAS
  // ============================================
  final List<String> foodRestrictions;
  final List<String> allergies;
  final String? notes;

  // ============================================
  // METADADOS
  // ============================================
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.initialWeightKg,
    this.currentWeightKg,
    this.goalWeightKg,
    this.waistCm,
    this.goal,
    this.activityLevel,
    this.foodRestrictions = const [],
    this.allergies = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// IMC (Índice de Massa Corporal)
  double? get bmi {
    if (heightCm == null || currentWeightKg == null) return null;
    if (heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return currentWeightKg! / (heightM * heightM);
  }

  /// Categoria do IMC (OMS)
  String? get bmiCategory {
    final value = bmi;
    if (value == null) return null;
    if (value < 18.5) return 'Abaixo do peso';
    if (value < 25) return 'Peso normal';
    if (value < 30) return 'Sobrepeso';
    if (value < 35) return 'Obesidade grau I';
    if (value < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }

  /// Quanto já perdeu/ganhou desde o início (em kg)
  double? get weightDelta {
    if (initialWeightKg == null || currentWeightKg == null) return null;
    return currentWeightKg! - initialWeightKg!;
  }

  /// Quanto falta para atingir a meta (em kg)
  double? get remainingToGoal {
    if (goalWeightKg == null || currentWeightKg == null) return null;
    return currentWeightKg! - goalWeightKg!;
  }

  /// Idade calculada a partir da data de nascimento
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  /// Risco cardiovascular baseado na circunferência abdominal
  /// (referência: OMS)
  String? get waistRisk {
    if (waistCm == null || gender == null) return null;

    if (gender == Gender.female) {
      if (waistCm! < 80) return 'Normal';
      if (waistCm! < 88) return 'Atenção';
      return 'Risco elevado';
    } else {
      if (waistCm! < 94) return 'Normal';
      if (waistCm! < 102) return 'Atenção';
      return 'Risco elevado';
    }
  }

  /// Relação cintura/altura (RCA) — indicador mais preciso que IMC
  double? get waistToHeightRatio {
    if (waistCm == null || heightCm == null || heightCm! <= 0) return null;
    return waistCm! / heightCm!;
  }

  /// Taxa Metabólica Basal (TMB) — fórmula de Mifflin-St Jeor
  /// Retorna kcal/dia
  double? get basalMetabolicRate {
    if (currentWeightKg == null ||
        heightCm == null ||
        age == null ||
        gender == null) {
      return null;
    }

    if (gender == Gender.male) {
      return (10 * currentWeightKg!) +
          (6.25 * heightCm!) -
          (5 * age!) +
          5;
    } else {
      return (10 * currentWeightKg!) +
          (6.25 * heightCm!) -
          (5 * age!) -
          161;
    }
  }

  /// Gasto calórico total estimado (TMB × fator de atividade)
  double? get totalDailyEnergyExpenditure {
    final tmb = basalMetabolicRate;
    if (tmb == null || activityLevel == null) return null;
    return tmb * activityLevel!.factor;
  }

  // ============================================
  // COPYWITH
  // ============================================
  PatientProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    Gender? gender,
    double? heightCm,
    double? initialWeightKg,
    double? currentWeightKg,
    double? goalWeightKg,
    double? waistCm,
    Goal? goal,
    ActivityLevel? activityLevel,
    List<String>? foodRestrictions,
    List<String>? allergies,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      waistCm: waistCm ?? this.waistCm,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      foodRestrictions: foodRestrictions ?? this.foodRestrictions,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // MOCK (dados de exemplo)
  // ============================================
  static PatientProfile mock() {
    return PatientProfile(
      id: 'mock-001',
      name: 'Maria Silva',
      email: 'maria.silva@email.com',
      phone: '(11) 99999-1234',
      birthDate: DateTime(1990, 5, 15),
      gender: Gender.female,
      heightCm: 165,
      initialWeightKg: 78.0,
      currentWeightKg: 72.4,
      goalWeightKg: 65.0,
      waistCm: 88,
      goal: Goal.lose,
      activityLevel: ActivityLevel.moderate,
      foodRestrictions: ['Lactose'],
      allergies: ['Amendoim'],
      notes: 'Pratica atividade física 3x por semana.',
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime.now(),
    );
  }
}

// ============================================
// ENUMS
// ============================================

enum Gender {
  female,
  male,
  other,
}

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.female:
        return 'Feminino';
      case Gender.male:
        return 'Masculino';
      case Gender.other:
        return 'Outro';
    }
  }
}

enum Goal {
  lose,
  maintain,
  gain,
}

extension GoalExtension on Goal {
  String get label {
    switch (this) {
      case Goal.lose:
        return 'Emagrecer';
      case Goal.maintain:
        return 'Manter peso';
      case Goal.gain:
        return 'Ganhar massa';
    }
  }

  String get icon {
    switch (this) {
      case Goal.lose:
        return '📉';
      case Goal.maintain:
        return '⚖️';
      case Goal.gain:
        return '💪';
    }
  }
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  intense,
  athlete,
}

extension ActivityLevelExtension on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentário';
      case ActivityLevel.light:
        return 'Leve';
      case ActivityLevel.moderate:
        return 'Moderado';
      case ActivityLevel.intense:
        return 'Intenso';
      case ActivityLevel.athlete:
        return 'Atleta';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Pouco ou nenhum exercício';
      case ActivityLevel.light:
        return '1-3x por semana';
      case ActivityLevel.moderate:
        return '3-5x por semana';
      case ActivityLevel.intense:
        return '6-7x por semana';
      case ActivityLevel.athlete:
        return '2x por dia';
    }
  }

  /// Fator multiplicador para cálculo de gasto calórico
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.intense:
        return 1.725;
      case ActivityLevel.athlete:
        return 1.9;
    }
  }
}