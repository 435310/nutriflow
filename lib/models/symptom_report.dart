/// ============================================
/// MODELO: RELATO DE SINTOMAS
/// ============================================
/// Guarda os sintomas, dificuldades e observações do paciente.
class SymptomReport {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final List<String> difficulties;
  final String? notes;

  const SymptomReport({
    required this.id,
    required this.date,
    this.symptoms = const [],
    this.difficulties = const [],
    this.notes,
  });

  /// Se não tem nada relatado
  bool get isEmpty =>
      symptoms.isEmpty && difficulties.isEmpty && (notes == null || notes!.isEmpty);

  /// Data formatada: "11/10/2026 às 20:30"
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} às '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Texto curto para exibir no card
  String get summary {
    final parts = <String>[];
    if (symptoms.isNotEmpty) {
      parts.add('${symptoms.length} sintoma${symptoms.length > 1 ? 's' : ''}');
    }
    if (difficulties.isNotEmpty) {
      parts.add('${difficulties.length} dificuldade${difficulties.length > 1 ? 's' : ''}');
    }
    if (parts.isEmpty && notes != null && notes!.isNotEmpty) {
      return 'Observação registrada';
    }
    return parts.isEmpty ? 'Sem relatos' : parts.join(' · ');
  }

  SymptomReport copyWith({
    String? id,
    DateTime? date,
    List<String>? symptoms,
    List<String>? difficulties,
    String? notes,
  }) {
    return SymptomReport(
      id: id ?? this.id,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      difficulties: difficulties ?? this.difficulties,
      notes: notes ?? this.notes,
    );
  }
}

// ============================================
// LISTAS DE OPÇÕES
// ============================================
class SymptomOptions {
  SymptomOptions._();

  static const List<String> symptoms = [
    'Dor de cabeça',
    'Cansaço / Fadiga',
    'Intestino preso',
    'Inchaço',
    'Náusea',
    'Tontura',
    'Insônia',
  ];

  static const List<String> difficulties = [
    'Fome excessiva',
    'Ansiedade',
    'Falta de tempo',
    'Comer fora',
    'Vontade de doce',
    'Fim de semana / social',
  ];
}