/// ============================================
/// MODELO: ANAMNESE (Primeira Consulta)
/// ============================================
class Anamnesis {
  final String id;
  final String patientId;
  final String? mainGoal;
  final String? healthConditions;
  final String? medications;
  final String? supplements;
  final String? bowelHabits;
  final String? sleepQuality;
  final String? waterIntake;
  final String? alcoholConsumption;
  final String? smoking;
  final String? physicalActivity;
  final String? foodAllergies;
  final String? foodIntolerances;
  final String? dietaryPreferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Anamnesis({
    required this.id,
    required this.patientId,
    this.mainGoal,
    this.healthConditions,
    this.medications,
    this.supplements,
    this.bowelHabits,
    this.sleepQuality,
    this.waterIntake,
    this.alcoholConsumption,
    this.smoking,
    this.physicalActivity,
    this.foodAllergies,
    this.foodIntolerances,
    this.dietaryPreferences,
    required this.createdAt,
    this.updatedAt,
  });

  /// Mock para testes
  static Anamnesis mock() {
    return Anamnesis(
      id: 'mock-anamnesis-001',
      patientId: 'mock-patient-001',
      mainGoal: 'Emagrecer 5kg e melhorar a disposição.',
      healthConditions: 'Nenhuma doença crônica diagnosticada.',
      medications: 'Nenhum.',
      supplements: 'Whey Protein ocasionalmente.',
      bowelHabits: 'Intestino preso às vezes.',
      sleepQuality: 'Dorme cerca de 7 horas por noite.',
      waterIntake: 'Cerca de 1,5 litros por dia.',
      alcoholConsumption: 'Socialmente aos fins de semana.',
      smoking: 'Não fuma.',
      physicalActivity: 'Caminhada 3x por semana.',
      foodAllergies: 'Nenhuma.',
      foodIntolerances: 'Lactose (leve).',
      dietaryPreferences: 'Gosta de comida brasileira, evita frituras.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: null,
    );
  }
}