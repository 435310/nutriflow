import 'nutritionist_dashboard.dart';

/// ============================================
/// FILTRO DE PACIENTES
/// ============================================
enum PatientFilter {
  all,
  evolving,
  attention,
  noInteraction,
}

extension PatientFilterExtension on PatientFilter {
  String get label {
    switch (this) {
      case PatientFilter.all:
        return 'Todos';
      case PatientFilter.evolving:
        return 'Evoluindo';
      case PatientFilter.attention:
        return 'Atenção';
      case PatientFilter.noInteraction:
        return 'Sem interação';
    }
  }

  String get emoji {
    switch (this) {
      case PatientFilter.all:
        return '👥';
      case PatientFilter.evolving:
        return '🟢';
      case PatientFilter.attention:
        return '🟡';
      case PatientFilter.noInteraction:
        return '🔴';
    }
  }

  PatientStatus? get status {
    switch (this) {
      case PatientFilter.all:
        return null;
      case PatientFilter.evolving:
        return PatientStatus.evolving;
      case PatientFilter.attention:
        return PatientStatus.attention;
      case PatientFilter.noInteraction:
        return PatientStatus.noInteraction;
    }
  }
}

// ============================================
// ORDENAÇÃO DE PACIENTES
// ============================================
enum PatientSort {
  lastActivity,
  nameAsc,
  nameDesc,
}

extension PatientSortExtension on PatientSort {
  String get label {
    switch (this) {
      case PatientSort.lastActivity:
        return 'Última atividade';
      case PatientSort.nameAsc:
        return 'Nome (A-Z)';
      case PatientSort.nameDesc:
        return 'Nome (Z-A)';
    }
  }

  /// Aplica a ordenação na lista de pacientes
  List<PatientSummary> apply(List<PatientSummary> patients) {
    final sorted = List<PatientSummary>.from(patients);

    switch (this) {
      case PatientSort.lastActivity:
        sorted.sort(
          (a, b) => b.lastActivityTime.compareTo(a.lastActivityTime),
        );
        break;
      case PatientSort.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PatientSort.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return sorted;
  }
}

// ============================================
// FUNÇÃO: FILTRAR E ORDENAR
// ============================================
/// Aplica filtro de status + busca por nome + ordenação
List<PatientSummary> filterAndSortPatients({
  required List<PatientSummary> patients,
  PatientFilter filter = PatientFilter.all,
  PatientSort sort = PatientSort.lastActivity,
  String searchQuery = '',
}) {
  // 1. Filtra por status
  var result = patients.where((patient) {
    if (filter.status == null) return true;
    return patient.status == filter.status;
  }).toList();

  // 2. Filtra por busca (nome)
  if (searchQuery.trim().isNotEmpty) {
    final query = searchQuery.trim().toLowerCase();
    result = result.where((patient) {
      return patient.name.toLowerCase().contains(query);
    }).toList();
  }

  // 3. Ordena
  return sort.apply(result);
}