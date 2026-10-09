/// ============================================
/// MODELO: PERFIL DO PACIENTE
/// ============================================
/// Representa os dados de um paciente no NutriFlow.
/// Este modelo é usado em todas as telas (perfil, dashboard, etc).
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
  final double? heightCm;       // Altura em centímetros
  final double? currentWeightKg; // Peso atual em kg
  final double? initialWeightKg; // Peso inicial (primeira consulta)
  final double? goalWeightKg;    // Meta de peso
  final Goal? goal;              // Objetivo

  // ============================================
  // RESTRIÇÕES E PREFERÊNCIAS
  // ============================================
  final List<String> foodRestrictions; // Ex: ["Lactose", "Glúten"]
  final List<String> allergies;        // Ex: ["Amendoim", "Frutos do mar"]
  final String? notes;                 // Observações gerais

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
    this.currentWeightKg,
    this.initialWeightKg,
    this.goalWeightKg,
    this.goal,
    this.foodRestrictions = const [],
    this.allergies = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // ============================================
  // GETTERS ÚTEIS
  // ============================================

  /// Calcula o IMC (Índice de Massa Corporal)
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

  // ============================================
  // CÓPIA COM ALTERAÇÕES (copyWith)
  // ============================================
  PatientProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    Gender? gender,
    double? heightCm,
    double? currentWeightKg,
    double? initialWeightKg,
    double? goalWeightKg,
    Goal? goal,
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
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      goal: goal ?? this.goal,
      foodRestrictions: foodRestrictions ?? this.foodRestrictions,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // DADOS DE EXEMPLO (para desenvolvimento)
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
      currentWeightKg: 72.4,
      initialWeightKg: 78.0,
      goalWeightKg: 65.0,
      goal: Goal.lose,
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
  lose,    // Emagrecer
  maintain, // Manter peso
  gain,    // Ganhar massa
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