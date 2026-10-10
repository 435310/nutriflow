/// ============================================
/// MODELO: DASHBOARD DO NUTRICIONISTA
/// ============================================
/// Dados agregados que o nutricionista vê na tela inicial.
class NutritionistDashboard {
  final int totalPatients;
  final int evolvingCount;
  final int attentionCount;
  final int noInteractionCount;
  final List<PatientSummary> recentPatients;
  final List<RecentActivity> recentActivities;

  const NutritionistDashboard({
    required this.totalPatients,
    required this.evolvingCount,
    required this.attentionCount,
    required this.noInteractionCount,
    this.recentPatients = const [],
    this.recentActivities = const [],
  });

  /// Mock com dados fictícios para desenvolvimento
  static NutritionistDashboard mock() {
    return NutritionistDashboard(
      totalPatients: 42,
      evolvingCount: 30,
      attentionCount: 8,
      noInteractionCount: 4,
      recentPatients: [
        PatientSummary(
          id: '1',
          name: 'Maria Silva',
          status: PatientStatus.evolving,
          lastActivity: 'Atualizou peso',
          lastActivityTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PatientSummary(
          id: '2',
          name: 'João Pedro Santos',
          status: PatientStatus.attention,
          lastActivity: 'Enviou exame',
          lastActivityTime: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        PatientSummary(
          id: '3',
          name: 'Carlos Eduardo Souza',
          status: PatientStatus.noInteraction,
          lastActivity: 'Sem interação',
          lastActivityTime: DateTime.now().subtract(const Duration(days: 8)),
        ),
        PatientSummary(
          id: '4',
          name: 'Ana Costa',
          status: PatientStatus.evolving,
          lastActivity: 'Registrou refeição',
          lastActivityTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        PatientSummary(
          id: '5',
          name: 'Beatriz Almeida',
          status: PatientStatus.attention,
          lastActivity: 'Poucos registros',
          lastActivityTime: DateTime.now().subtract(const Duration(days: 3)),
        ),
        PatientSummary(
          id: '6',
          name: 'Rafael Lima',
          status: PatientStatus.evolving,
          lastActivity: 'Meta atingida',
          lastActivityTime: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      recentActivities: [
        RecentActivity(
          type: ActivityType.weightUpdate,
          patientName: 'Maria Silva',
          description: 'Atualizou peso para 72,4 kg',
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RecentActivity(
          type: ActivityType.examUpload,
          patientName: 'João Pedro',
          description: 'Enviou exame de sangue',
          time: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        RecentActivity(
          type: ActivityType.mealLog,
          patientName: 'Carlos Eduardo',
          description: 'Registrou almoço',
          time: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        RecentActivity(
          type: ActivityType.message,
          patientName: 'Ana Costa',
          description: 'Enviou mensagem',
          time: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ],
    );
  }
}

// ============================================
// MODELO: RESUMO DE PACIENTE
// ============================================
class PatientSummary {
  final String id;
  final String name;
  final PatientStatus status;
  final String lastActivity;
  final DateTime lastActivityTime;

  const PatientSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.lastActivity,
    required this.lastActivityTime,
  });

  /// Texto amigável do tempo decorrido
  /// "2h atrás", "3 dias atrás", "agora"
  String get timeAgo {
    final diff = DateTime.now().difference(lastActivityTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}sem';
    return '${(diff.inDays / 30).floor()}m';
  }
}

// ============================================
// MODELO: ATIVIDADE RECENTE
// ============================================
class RecentActivity {
  final ActivityType type;
  final String patientName;
  final String description;
  final DateTime time;

  const RecentActivity({
    required this.type,
    required this.patientName,
    required this.description,
    required this.time,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ============================================
// ENUMS
// ============================================
enum PatientStatus {
  evolving,     // 🟢 evoluindo
  attention,    // 🟡 atenção
  noInteraction, // 🔴 sem interação
}

extension PatientStatusExtension on PatientStatus {
  String get label {
    switch (this) {
      case PatientStatus.evolving:
        return 'Evoluindo';
      case PatientStatus.attention:
        return 'Atenção';
      case PatientStatus.noInteraction:
        return 'Sem interação';
    }
  }

  String get emoji {
    switch (this) {
      case PatientStatus.evolving:
        return '🟢';
      case PatientStatus.attention:
        return '🟡';
      case PatientStatus.noInteraction:
        return '🔴';
    }
  }
}

enum ActivityType {
  weightUpdate,
  examUpload,
  mealLog,
  message,
}

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.weightUpdate:
        return 'Peso atualizado';
      case ActivityType.examUpload:
        return 'Exame enviado';
      case ActivityType.mealLog:
        return 'Refeição registrada';
      case ActivityType.message:
        return 'Mensagem';
    }
  }
}