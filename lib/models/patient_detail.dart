import 'meal.dart';
import 'patient_profile.dart';
import 'weight_entry.dart';

/// ============================================
/// MODELO: PACIENTE DETALHADO (visão do nutricionista)
/// ============================================
/// Reúne todos os dados de um paciente em um só lugar.
class PatientDetail {
  final PatientProfile profile;
  final List<WeightEntry> weightHistory;
  final List<Meal> recentMeals;
  final List<PatientExam> recentExams;
  final List<PatientMessage> recentMessages;

  const PatientDetail({
    required this.profile,
    this.weightHistory = const [],
    this.recentMeals = const [],
    this.recentExams = const [],
    this.recentMessages = const [],
  });

  /// Mock completo com dados fictícios
  static PatientDetail mock() {
    final profile = PatientProfile.mock();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return PatientDetail(
      profile: profile,
      weightHistory: WeightEntry.mock(),
      recentMeals: [
        Meal(
          id: 'm1',
          type: MealType.breakfast,
          dateTime: today.add(const Duration(hours: 7, minutes: 30)),
          foods: const [
            FoodItem(name: 'Pão integral', quantity: 2, unit: 'fatias'),
            FoodItem(name: 'Ovo mexido', quantity: 2, unit: 'unidades'),
          ],
        ),
        Meal(
          id: 'm2',
          type: MealType.lunch,
          dateTime: today.add(const Duration(hours: 12, minutes: 30)),
          foods: const [
            FoodItem(name: 'Frango grelhado', quantity: 150, unit: 'g'),
            FoodItem(name: 'Arroz integral', quantity: 100, unit: 'g'),
            FoodItem(name: 'Salada verde', quantity: 1, unit: 'prato'),
          ],
        ),
      ],
      recentExams: [
        PatientExam(
          id: 'e1',
          name: 'Hemograma completo',
          date: now.subtract(const Duration(days: 5)),
          status: ExamStatus.reviewed,
        ),
        PatientExam(
          id: 'e2',
          name: 'Glicemia de jejum',
          date: now.subtract(const Duration(days: 12)),
          status: ExamStatus.reviewed,
        ),
        PatientExam(
          id: 'e3',
          name: 'Colesterol total',
          date: now.subtract(const Duration(days: 2)),
          status: ExamStatus.pending,
        ),
      ],
      recentMessages: [
        PatientMessage(
          id: 'msg1',
          content: 'Olá, doutora! Posso trocar o jantar por sopa?',
          sentAt: now.subtract(const Duration(hours: 3)),
          fromPatient: true,
          isRead: false,
        ),
        PatientMessage(
          id: 'msg2',
          content: 'Claro! Desde que tenha proteína e legumes.',
          sentAt: now.subtract(const Duration(hours: 2)),
          fromPatient: false,
          isRead: true,
        ),
      ],
    );
  }
}

// ============================================
// MODELO: EXAME
// ============================================
class PatientExam {
  final String id;
  final String name;
  final DateTime date;
  final ExamStatus status;

  const PatientExam({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'hoje';
    if (diff.inDays == 1) return 'ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} sem atrás';
    return '${(diff.inDays / 30).floor()} meses atrás';
  }
}

enum ExamStatus {
  pending,   // aguardando análise
  reviewed,  // já analisado
}

extension ExamStatusExtension on ExamStatus {
  String get label {
    switch (this) {
      case ExamStatus.pending:
        return 'Aguardando análise';
      case ExamStatus.reviewed:
        return 'Analisado';
    }
  }
}

// ============================================
// MODELO: MENSAGEM
// ============================================
class PatientMessage {
  final String id;
  final String content;
  final DateTime sentAt;
  final bool fromPatient;
  final bool isRead;

  const PatientMessage({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.fromPatient,
    this.isRead = true,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(sentAt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}