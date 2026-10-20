/// ============================================
/// MODELO: PERFIL DO NUTRICIONISTA
/// ============================================
class NutritionistProfile {
  final String id;
  final String name;
  final String email;
  final String crn;
  final String specialty;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NutritionistProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.crn,
    required this.specialty,
    this.bio,
    required this.createdAt,
    this.updatedAt,
  });

  /// Mock para desenvolvimento
  static NutritionistProfile mock() {
    return NutritionistProfile(
      id: 'nutri-001',
      name: 'Dra. Ana Costa',
      email: 'ana.costa@nutriflow.com',
      crn: 'CRN-3 12345',
      specialty: 'Nutrição Clínica e Esportiva',
      bio: 'Especialista em emagrecimento saudável e reeducação alimentar.',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    );
  }

  NutritionistProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? crn,
    String? specialty,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NutritionistProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      crn: crn ?? this.crn,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}