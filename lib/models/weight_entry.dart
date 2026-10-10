/// ============================================
/// MODELO: REGISTRO DE PESO
/// ============================================
/// Representa uma pesagem do paciente em uma data.
class WeightEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? notes;

  const WeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.notes,
  });

  /// Data formatada: "09/10/2026"
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Data curta: "09/10"
  String get shortDate {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  WeightEntry copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? notes,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }

  /// Lista de exemplo para desenvolvimento
  static List<WeightEntry> mock() {
    final now = DateTime.now();
    return [
      WeightEntry(
        id: '1',
        date: now.subtract(const Duration(days: 90)),
        weightKg: 78.0,
      ),
      WeightEntry(
        id: '2',
        date: now.subtract(const Duration(days: 75)),
        weightKg: 77.2,
      ),
      WeightEntry(
        id: '3',
        date: now.subtract(const Duration(days: 60)),
        weightKg: 76.1,
      ),
      WeightEntry(
        id: '4',
        date: now.subtract(const Duration(days: 45)),
        weightKg: 75.0,
      ),
      WeightEntry(
        id: '5',
        date: now.subtract(const Duration(days: 30)),
        weightKg: 74.2,
      ),
      WeightEntry(
        id: '6',
        date: now.subtract(const Duration(days: 15)),
        weightKg: 73.2,
      ),
      WeightEntry(
        id: '7',
        date: now.subtract(const Duration(days: 7)),
        weightKg: 72.7,
      ),
      WeightEntry(
        id: '8',
        date: now,
        weightKg: 72.4,
      ),
    ];
  }
}