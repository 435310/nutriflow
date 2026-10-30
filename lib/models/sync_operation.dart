/// ============================================
/// OPERAÇÃO PENDENTE DE SINCRONIZAÇÃO
/// ============================================
enum SyncEntity { meal, weight, symptom, profile, anamnesis }

enum SyncAction { upsert, delete }

class SyncOperation {
  /// Identifica esta operação específica (muda a cada nova tentativa de salvar o mesmo item).
  final String opId;
  final SyncEntity entity;
  final String entityId;
  final SyncAction action;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  const SyncOperation({
    required this.opId,
    required this.entity,
    required this.entityId,
    required this.action,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  /// Chave do item afetado: só existe uma operação pendente por item.
  String get key => '${entity.name}:$entityId';

  SyncOperation copyWith({int? attempts, String? lastError}) {
    return SyncOperation(
      opId: opId,
      entity: entity,
      entityId: entityId,
      action: action,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'opId': opId,
        'entity': entity.name,
        'entityId': entityId,
        'action': action.name,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
        'lastError': lastError,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      opId: json['opId'] as String,
      entity: SyncEntity.values.byName(json['entity'] as String),
      entityId: json['entityId'] as String,
      action: SyncAction.values.byName(json['action'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );
  }
}